#include "ApplicationDefinitions.h"
#include "BeaconMessage.h"
#include "Pos.h"
#include "Result.h"
#include "math.h"

module BlindC {
	uses interface Boot;

	uses interface SplitControl as RadioControl;
	uses interface Receive as BeaconMsgReceive;
	uses interface AMSend as BeaconMsgSend;
	uses interface CC2420Packet as BeaconPacket;

	uses interface SplitControl as SerialControl;
	uses interface AMSend as SerialMsgSend;
	uses interface Packet as SerialPacket;

	uses interface Timer<TMilli> as CalcPosTimer;
	uses interface Timer<TMilli> as SendResultTimer;

	uses interface Leds;

	uses interface LocalTime <TMilli>;

} implementation {
	//offset pari a 45 
	uint16_t LUT[80] = {1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 5, 5, 6, 7, 7, 8, 10, 11, 12, 14, 15, 17, 19, 22, 25, 28, 31, 35, 39, 44, 50, 56, 63, 70, 79, 89, 100, 112, 125, 141, 158, 177, 199, 223, 251, 281, 316, 354, 398, 446, 501, 562, 630, 707, 794, 891, 1000, 1122, 1258, 1412, 1584, 1778, 1995, 2238, 2511, 2818, 3162, 3548, 3981, 4466, 5011, 5623, 6309, 7079, 7943, 8912, 10000};
	uint16_t offsetRSSI = 45;
	Pos_t posBlindA; //pos_t del blind con algoritmo A
	Pos_t posBlindB; //pos_t del blind con algoritmo B
	uint8_t minX, maxX, minY, maxY; //min e max delle coordinate della griglia
	uint16_t step = STEP_SIZE; //step della griglia
	uint16_t distA[MAX_ANCHOR];
	uint16_t distBX[MAX_ANCHOR];
	uint16_t distBY[MAX_ANCHOR];
	uint16_t qualA[MAX_ANCHOR];
	uint16_t qualBX[MAX_ANCHOR];
	uint16_t qualBY[MAX_ANCHOR];
	uint16_t iterA, iterB;
	Pos_t posAnchors[MAX_ANCHOR]; //array delle posizioni delle ancore
	bool foundedAnchors[MAX_ANCHOR]; //array di bool per tenere traccia delle ancore trovate a runtime
	uint8_t bufferIndex[MAX_ANCHOR]; //array degli indici relativi al buffer per renderlo circolare
	uint16_t buffer[MAX_ANCHOR][BUFFER_DEPTH]; //matrice buffer degli rssi dei messaggi ricevuti dalle ancore
	bool bufferReady[MAX_ANCHOR]; //ogni elemento diventa 1 quando il relativo buffer è pieno
	uint32_t avg_RSSI[MAX_ANCHOR]; //array delle medie RSSI rispetto ad ogni ancora
	bool calcPosStarted; //booleana per segnare l'avvio del task per il calcolo della posizione
	bool sendResultStarted = FALSE; //booleana per segnare l'avvio del task per inviare i risultati alla seriale

	message_t serialMsg; //pacchetto di appoggio utilizzato per comunicazione seriale

	nx_struct Result_t resultsToSendQueue[RESULTS_QUEUE_DEPTH]; //coda dei risultati da inviare
	uint16_t resultsQueueFront, resultsQueueRear; //indice per inserire/estrarre il risultato nella/dalla coda

	void init();//inizializza le variabili d'ambiente
	uint16_t getRssi(message_t *msg); //estrare il valore rssi dal beacon ricevuto
	void handleBeacon(Beacon_msg* beaconMsg, uint16_t rssi); //invocato ad ogni ricezione di un beacon
	void addToBuffer(uint8_t idAnchor, uint16_t rssi); //aggiunge al buffer il valore rssi del beacon ricevuto da un ancora
	void calcMinMaxGrid(Pos_t posAnchor); //aggiorna gli estremi della griglia in base alle coordinate delle ancore
	void increaseBufferIndex(uint8_t id); //incrementa o resetta l'indice del buffer rendendolo circolare
	bool IsBufferReady(); //controllo sul buffer, true se questo è pieno
	task void calcPosTask(); //calcolo posizione del nodo blind
	void sendToSerial(); //invio pachetto alla seriale
	void AlgoA();
	void AlgoB();

	Result_t createResult(uint16_t iter, uint8_t idAlgo, uint8_t stateAlgo);
	void enqueueResult(Result_t result); //funzione per inserire nella coda dei risultati
	Result_t dequeueResult();//funzione per prelevare dalla coda dei risultati

	void sendToSerialOld(Result_t result);

	event void Boot.booted(){
		init();
		//avvio processi Serial e Radio
		call RadioControl.start();
		call SerialControl.start();
	}

	// inizializzazione delle variabili
	void init(){
		//affinchè calcMinMaxGrid funzioni, i min devono essere inizializzati ai valori massimi e i max ai valori minimi
		uint8_t i;
		for (i = 0; i < MAX_ANCHOR; ++i){
			foundedAnchors[i] = FALSE;
			bufferIndex[i] = 0;
		}

		calcPosStarted = FALSE;

		minX = 255;
		maxX = 0;
		minY = 255;
		maxY = 0;

		posBlindA.coordinate_x = 0;
		posBlindA.coordinate_y = 0;
		posBlindB.coordinate_x = 0;
		posBlindB.coordinate_y = 0;

		iterA = 0;
		iterB = 0;

		resultsQueueRear = -1;
		resultsQueueFront = -1;
	}

	event void RadioControl.startDone(error_t err){
		if(err == SUCCESS){
			//Ok
		}else{
			call RadioControl.start();
		}
	}

	event void RadioControl.stopDone(error_t result){}

	event void SerialControl.startDone(error_t err){
		if(err == SUCCESS){
			//Ok
		}else{
			call RadioControl.start();
		}
	}

	event void SerialControl.stopDone(error_t result){}

	event message_t* BeaconMsgReceive.receive(message_t* msg, void* payload, uint8_t len) {
		if (len == sizeof(Beacon_msg)) { //prendo solo messaggi delle dimensioni di Beacon_msg
			Beacon_msg* beaconMsg = (Beacon_msg*) payload;
			uint16_t rssi = getRssi(msg);

			call Leds.led0Toggle(); //notifico la ricezione di un beacon

			handleBeacon(beaconMsg, rssi); //gestisco il beacon ricevuto
  		}
  		return msg;
	}

	//ottengo il valore rssi del messaggio
	uint16_t getRssi(message_t *msg){
		return (uint16_t) call BeaconPacket.getRssi(msg);
  	}

  	//gestione del beacon ricevuto
  	void handleBeacon(Beacon_msg* beaconMsg, uint16_t rssi){
  		uint8_t idAnchor = beaconMsg->anchor_id;
  		idAnchor = idAnchor - 1; //perchè abbiamo considerato che gli id delle ancore siano numerate da 1 a MAX_ANCHOR

  		if (!foundedAnchors[idAnchor]){ //aggiungo l'ancora nuova se non l'avevo trovata
		  	//Pos_t posAnchor = {beaconMsg->coordinate_x, beaconMsg->coordinate_y}; //creo il pos_t da aggiungere con le coordinate dell'ancora
		  	//posAnchor = (Pos_t) {beaconMsg->coordinate_x, beaconMsg->coordinate_y}; //assegno a pos le coordinate della nuova ancora
		  	Pos_t posAnchor;
		  	posAnchor.coordinate_x = beaconMsg->coordinate_x;
		  	posAnchor.coordinate_y = beaconMsg->coordinate_y;
			posAnchors[idAnchor] = posAnchor; //aggiungo il pos_t all'array
		
			calcMinMaxGrid(posAnchor); //calcolo gli estremi della griglia
		
			foundedAnchors[idAnchor] = TRUE; //imposto di aver trovato l'ancora con lo specifico id
  		}
  		addToBuffer(idAnchor, rssi); //aggiungo il valore rssi del beacon mandato dall'ancora al buffer

  		if (!calcPosStarted){ //se il processo di calcolo della pos non è stato ancora avviato
  			if (IsBufferReady()){	//se il buffer è pieno avvio il process di calcolo della pos
  				call Leds.led1Toggle(); //notifico che il buffer è pieno
  				calcPosStarted = TRUE;
  				call CalcPosTimer.startPeriodic(CALC_POS_INTERVAL_MS); //avvio timer per il calcolo della pos
  			}
  		}
   	}

  	//calcolo degli estremi della griglia quadrata
  	void calcMinMaxGrid(Pos_t posAnchor){
  		if (posAnchor.coordinate_x < minX) minX = posAnchor.coordinate_x;
  		if (posAnchor.coordinate_x > maxX) maxX = posAnchor.coordinate_x;
  		if (posAnchor.coordinate_y < minY) minY = posAnchor.coordinate_y;
  		if (posAnchor.coordinate_y > maxY) maxY = posAnchor.coordinate_y;
  	}

  	//aggiorna il buffer degli rssi
  	void addToBuffer(uint8_t idAnchor, uint16_t rssi){
  		uint8_t row = idAnchor;
  		uint8_t column = bufferIndex[idAnchor];
  		buffer[row][column] = rssi;
  		increaseBufferIndex(idAnchor);
  	}

  	//rende il buffer circolare
  	void increaseBufferIndex(uint8_t id){
  		bufferIndex[id] = bufferIndex[id] + 1;
  		//resetto l'indice del buffer nel caso sia oltre il massimo
  		if (bufferIndex[id] == BUFFER_DEPTH){
  			bufferIndex[id] = 0;
  			bufferReady[id] = TRUE;
  		}
  	}

  	bool IsBufferReady(){
  		uint8_t i;
  		for (i = 0; i < MAX_ANCHOR; ++i){
  			if(!bufferReady[i]) return FALSE;
  		}
  		return TRUE;
  	}

  	event void CalcPosTimer.fired() {
  		post calcPosTask();
   	}

   	event void SendResultTimer.fired() {
  		sendToSerial();
   	}

	event void BeaconMsgSend.sendDone(message_t *m,error_t error){}

	event void SerialMsgSend.sendDone(message_t *m,error_t error){}

	//invio la posizione stimata dall'algoritmo (non funzionante, ovvero perde i messaggi, se richiamato con una frequenza elevata)
	void sendToSerialOld(Result_t result){
		Result_t* resultToSend;

		resultToSend = (Result_t*) (call SerialPacket.getPayload(&serialMsg, sizeof(Result_t)));

		resultToSend->iterazione = result.iterazione;
		resultToSend->id_algoritmo = result.id_algoritmo;
		resultToSend->state_algoritmo = result.state_algoritmo;
		resultToSend->timestamp = result.timestamp;
		resultToSend->coordinate_x = result.coordinate_x;
		resultToSend->coordinate_y = result.coordinate_y;

		call SerialMsgSend.send(AM_BROADCAST_ADDR, &serialMsg, sizeof(Result_t));
	}

	//invio la posizione stimata dall'algoritmo
	void sendToSerial(){
		Result_t result = dequeueResult();

		Result_t* resultToSend;

		resultToSend = (Result_t*) (call SerialPacket.getPayload(&serialMsg, sizeof(Result_t)));

		resultToSend->iterazione = result.iterazione;
		resultToSend->id_algoritmo = result.id_algoritmo;
		resultToSend->state_algoritmo = result.state_algoritmo;
		resultToSend->timestamp = result.timestamp;
		resultToSend->coordinate_x = result.coordinate_x;
		resultToSend->coordinate_y = result.coordinate_y;

		call SerialMsgSend.send(AM_BROADCAST_ADDR, &serialMsg, sizeof(Result_t));
	}

	void enqueueResult(Result_t result){
		if((resultsQueueFront == 0 && resultsQueueRear == RESULTS_QUEUE_DEPTH - 1) || (resultsQueueFront == resultsQueueRear + 1)){
			/* queue full */
			return;
		}else if(resultsQueueRear == - 1){
			resultsQueueRear++;
			resultsQueueFront++;
		}else if(resultsQueueRear == (RESULTS_QUEUE_DEPTH - 1) && resultsQueueFront > 0){
			resultsQueueRear = 0;
		}else{
			resultsQueueRear++;
		}
		resultsToSendQueue[resultsQueueRear].iterazione = result.iterazione;
		resultsToSendQueue[resultsQueueRear].id_algoritmo = result.id_algoritmo;
		resultsToSendQueue[resultsQueueRear].state_algoritmo = result.state_algoritmo;
		resultsToSendQueue[resultsQueueRear].timestamp = result.timestamp;
		resultsToSendQueue[resultsQueueRear].coordinate_x = result.coordinate_x;
		resultsToSendQueue[resultsQueueRear].coordinate_y = result.coordinate_y;
	}

	Result_t dequeueResult(){
		Result_t result;
		if(resultsQueueFront == - 1){
			/* queue empty */;
		}else if(resultsQueueFront == resultsQueueRear){
			result.iterazione = resultsToSendQueue[resultsQueueFront].iterazione;
			result.id_algoritmo = resultsToSendQueue[resultsQueueFront].id_algoritmo;
			result.state_algoritmo = resultsToSendQueue[resultsQueueFront].state_algoritmo;
			result.timestamp = resultsToSendQueue[resultsQueueFront].timestamp;
			result.coordinate_x = resultsToSendQueue[resultsQueueFront].coordinate_x;
			result.coordinate_y = resultsToSendQueue[resultsQueueFront].coordinate_y;

			resultsQueueFront = - 1;
			resultsQueueRear = - 1;
		}else{
			result.iterazione = resultsToSendQueue[resultsQueueFront].iterazione;
			result.id_algoritmo = resultsToSendQueue[resultsQueueFront].id_algoritmo;
			result.state_algoritmo = resultsToSendQueue[resultsQueueFront].state_algoritmo;
			result.timestamp = resultsToSendQueue[resultsQueueFront].timestamp;
			result.coordinate_x = resultsToSendQueue[resultsQueueFront].coordinate_x;
			result.coordinate_y = resultsToSendQueue[resultsQueueFront].coordinate_y;

			resultsQueueFront++;
		}

		return result;
	}

	Result_t createResult(uint16_t iter, uint8_t idAlgo, uint8_t stateAlgo){
		Result_t result;

		result.iterazione = iter;
		result.id_algoritmo = idAlgo;
		result.state_algoritmo = stateAlgo;
		result.timestamp = call LocalTime.get();

		if (idAlgo == ID_ALGO_A){
			result.coordinate_x = posBlindA.coordinate_x;
			result.coordinate_y = posBlindA.coordinate_y;
		}else if(idAlgo == ID_ALGO_B){
			result.coordinate_x = posBlindB.coordinate_x;
			result.coordinate_y = posBlindB.coordinate_y;
		}

		return result;
	}

	//task per il calcolo della posizione del Blind
   	task void calcPosTask(){
   		Result_t result1;
   		Result_t result2;
   		Result_t result3;
   		Result_t result4;

		call Leds.led2On(); //notifico inizio calcolo della posizione

		result1 = createResult(iterA, STATE_START_ALGO, ID_ALGO_A);
		enqueueResult(result1);
		//sendToSerialOld(result1);
		AlgoA();
		result2 = createResult(iterA, STATE_END_ALGO, ID_ALGO_A);
		enqueueResult(result2);
		//sendToSerialOld(result2);
		iterA++;

		result3 = createResult(iterB, STATE_START_ALGO, ID_ALGO_B);
		enqueueResult(result3);
		//sendToSerialOld(result3);
		AlgoB();
		result4 = createResult(iterB, STATE_END_ALGO, ID_ALGO_B);
		enqueueResult(result4);
		//sendToSerialOld(result4);
		iterB++;

		if (!sendResultStarted) call SendResultTimer.startPeriodic(SEND_RESULT_INTERVAL_MS); //avvio timer per mandare i risultati alla seriale

		call Leds.led2Off(); //notifico fine calcolo della posizione
   	}

   	//algoritmo con ricerca per ogni punto della griglia
   	void AlgoA(){
		uint8_t i, j;
		uint32_t sum = 0, average;
		uint16_t xsp, ysp, devstd = 0, min_ds = 65535;

		/* RSSI Buffer averages */
		for (i = 0; i < MAX_ANCHOR; i++){
			average = 0;
			for (j = 0; j < BUFFER_DEPTH; j++) 
				average += buffer[i][j];
			/* NEXT TIME: consider >> x with BUFFER_DEPTH = 2^x */
			average /= BUFFER_DEPTH;
			avg_RSSI[i] = average;
		}

		/* Controllo di ogni posizione della griglia */
		/* For each supposed position... */
		for (xsp = minX; xsp <= maxX; xsp = xsp + step){
			for (ysp = minY; ysp <= maxY; ysp = ysp + step){
				/* Pseudo distance (1 + d2) */
				for (j = 0; j < MAX_ANCHOR; j++){
					distA[j] = 1 +
						(xsp - posAnchors[j].coordinate_x) * (xsp - posAnchors[j].coordinate_x) + 
						(ysp - posAnchors[j].coordinate_y) * (ysp - posAnchors[j].coordinate_y);						
				}

				/* Quality function */
				for (j = 0; j < MAX_ANCHOR; j++) 
					qualA[j] = LUT[avg_RSSI[j] + offsetRSSI] * distA[j];

				average = 0;
				for (j = 0; j < MAX_ANCHOR; j++) /* NEXT TIME: merge two "for" */
					average += qualA[j];
				average /= MAX_ANCHOR;

				sum = 0;
				for(j = 0; j < MAX_ANCHOR; j++)
					sum += (qualA[j] - average) * (qualA[j] - average);
				devstd = sqrtf(sum / MAX_ANCHOR); /* NEXT TIME: avoid sqrt */

				/* Check for min devstd */
				if (devstd < min_ds){
					min_ds = devstd;
					posBlindA.coordinate_x = xsp;
					posBlindA.coordinate_y = ysp;
				}
			}
		}
   	}

   	//algoritmo con ricerca lungo gli assi della griglia
   	void AlgoB(){
		uint8_t i, j;
		uint32_t sum = 0, average;
		uint16_t xsp, ysp, devstd = 0, min_ds = 65535;

		/* RSSI Buffer averages */
		for (i = 0; i < MAX_ANCHOR; i++){
			average = 0;
			for (j = 0; j < BUFFER_DEPTH; j++) 
				average += buffer[i][j];
			/* NEXT TIME: consider >> x with BUFFER_DEPTH = 2^x */
			average /= BUFFER_DEPTH;
			avg_RSSI[i] = average;
		}

		/* Controllo di ogni posizione della griglia */
		/* For each supposed position... */
		for (xsp = minX; xsp <= maxX; xsp = xsp + step){
			/* Pseudo distanceX(1 + d2) */
			for (j = 0; j < MAX_ANCHOR; j++){
				distBX[j] = 1 +(xsp - posAnchors[j].coordinate_x) * (xsp - posAnchors[j].coordinate_x);
			}

			/* Quality function */
			for (j = 0; j < MAX_ANCHOR; j++) 
				qualBX[j] = LUT[avg_RSSI[j] + offsetRSSI] * distBX[j];

			average = 0;
			for (j = 0; j < MAX_ANCHOR; j++) /* NEXT TIME: merge two "for" */
				average += qualBX[j];
			average /= MAX_ANCHOR;

			sum = 0;
			for(j = 0; j < MAX_ANCHOR; j++)
				sum += (qualBX[j] - average) * (qualBX[j] - average);
			devstd = sqrtf(sum / MAX_ANCHOR); /* NEXT TIME: avoid sqrt */

			/* Check for min devstd */
			if (devstd < min_ds){
				min_ds = devstd;
				posBlindB.coordinate_x = xsp;
			}	
		}

		for (ysp = minY; ysp <= maxY; ysp = ysp + step){
				/* Pseudo distanceY(1 + d2) */
			for (j = 0; j < MAX_ANCHOR; j++){
				distBY[j] = 1 +(ysp - posAnchors[j].coordinate_y) * (ysp - posAnchors[j].coordinate_y);
			}

			/* Quality function */
			for (j = 0; j < MAX_ANCHOR; j++) 
				qualBY[j] = LUT[avg_RSSI[j] + offsetRSSI] * distBY[j];

			average = 0;
			for (j = 0; j < MAX_ANCHOR; j++) /* NEXT TIME: merge two "for" */
				average += qualBY[j];
			average /= MAX_ANCHOR;

			sum = 0;
			for(j = 0; j < MAX_ANCHOR; j++)
				sum += (qualBY[j] - average) * (qualBY[j] - average);
			devstd = sqrtf(sum / MAX_ANCHOR); /* NEXT TIME: avoid sqrt */

			/* Check for min devstd */
			if (devstd < min_ds){
				min_ds = devstd;
				posBlindB.coordinate_y = ysp;
			}	
		}
   	}
}