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
	uses interface AMSend as SerialBeaconRecSend;
	uses interface Packet as SerialPacket;

	uses interface Timer<TMilli> as CalcPosTimer;

	uses interface Leds;

	uses interface LocalTime <TMilli>;

} implementation {
	uint16_t offsetRSSI = 50; //valore minimo Rssi in modulo
	Pos_t posBlindA; //pos_t del blind con algoritmo A
	Pos_t posBlindB; //pos_t del blind con algoritmo B
	uint8_t minX, maxX, minY, maxY; //min e max delle coordinate della griglia
	uint16_t step = STEP_SIZE; //step della griglia
	uint16_t iterAlgo;
	Pos_t posAnchors[MAX_ANCHOR]; //array delle posizioni delle ancore
	bool foundedAnchors[MAX_ANCHOR]; //array di bool per tenere traccia delle ancore trovate a runtime
	uint8_t bufferIndex[MAX_ANCHOR]; //array degli indici relativi al buffer per renderlo circolare
	uint16_t buffer[MAX_ANCHOR][BUFFER_DEPTH]; //matrice buffer degli rssi dei messaggi ricevuti dalle ancore
	uint16_t bufferCopy[MAX_ANCHOR][BUFFER_DEPTH]; //copia buffer
	bool bufferReady[MAX_ANCHOR]; //ogni elemento diventa 1 quando il relativo buffer è pieno
	bool calcPosStarted; //booleana per segnare l'avvio del task per il calcolo della posizione

	message_t serialMsg; //pacchetto di appoggio utilizzato per comunicazione seriale
	message_t serialMsg2; //pacchetto di appoggio utilizzato per comunicazione seriale

	void init();//inizializza le variabili d'ambiente
	int8_t getRssi(message_t *msg); //estrare il valore rssi dal beacon ricevuto
	void handleBeacon(Beacon_msg* beaconMsg, int8_t rssi); //invocato ad ogni ricezione di un beacon
	void addToBuffer(uint8_t idAnchor, int8_t rssi); //aggiunge al buffer il valore rssi del beacon ricevuto da un ancora
	void calcMinMaxGrid(Pos_t posAnchor); //aggiorna gli estremi della griglia in base alle coordinate delle ancore
	void increaseBufferIndex(uint8_t id); //incrementa o resetta l'indice del buffer rendendolo circolare
	bool IsBufferReady(); //controllo sul buffer, true se questo è pieno
	task void calcPosTask(); //calcolo posizione del nodo blind
	void sendToSerial(Result_t result); //invio pachetto alla seriale
	void sendBeaconRecToSerial(BeaconRec_t beaconRec); //invio pachetto alla seriale
	void AlgoA(); //Algoritmo di Localizzazione A
	void AlgoB(); //Algoritmo di Localizzazione B

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

		iterAlgo = 0;
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
			call SerialControl.start();
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
	int8_t getRssi(message_t *msg){
		return (int8_t) call BeaconPacket.getRssi(msg);
  	}

  	//gestione del beacon ricevuto
  	void handleBeacon(Beacon_msg* beaconMsg, int8_t rssi){
  		BeaconRec_t beaconRec;//beacon da rigirare alla seriale
  		uint8_t idAnchor = beaconMsg->anchor_id;

  		//invio ala seriale del beacon ricevuto con il timestamp di ricezione
  		beaconRec.idAnchor = idAnchor;
		beaconRec.timestamp =  call LocalTime.get();
		beaconRec.rssi = rssi;
		beaconRec.coordinate_x = beaconMsg->coordinate_x;
		beaconRec.coordinate_y = beaconMsg->coordinate_y;
		sendBeaconRecToSerial(beaconRec);

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
  	void addToBuffer(uint8_t idAnchor, int8_t rssi){
  		uint8_t row = idAnchor;
  		uint8_t column = bufferIndex[idAnchor];
  		buffer[row][column] = rssi + offsetRSSI; //aggiungo l'offset

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
  		uint8_t i, j;
  			for (i = 0; i<MAX_ANCHOR; i++) 
    			for (j = 0; j<BUFFER_DEPTH; j++) 
      				bufferCopy[i][j] = buffer[i][j];
  		post calcPosTask();
   	}

	event void BeaconMsgSend.sendDone(message_t *m,error_t error){}

	event void SerialMsgSend.sendDone(message_t *m,error_t error){}

	event void SerialBeaconRecSend.sendDone(message_t *m,error_t error){}

	//invio la posizione stimata dall'algoritmo (non funzionante, ovvero perde i messaggi, se richiamato con una frequenza elevata)
	void sendToSerial(Result_t result){
		Result_t* resultToSend;

		resultToSend = (Result_t*) (call SerialPacket.getPayload(&serialMsg, sizeof(Result_t)));

		resultToSend->iterazione = result.iterazione;
		resultToSend->timestamp_inizio_A = result.timestamp_inizio_A;
		resultToSend->timestamp_fine_A = result.timestamp_fine_A;
		resultToSend->timestamp_inizio_B = result.timestamp_inizio_B;
		resultToSend->timestamp_fine_B = result.timestamp_fine_B;
		resultToSend->coordinate_x_A = result.coordinate_x_A;
		resultToSend->coordinate_y_A = result.coordinate_y_A;
		resultToSend->coordinate_x_B = result.coordinate_x_B;
		resultToSend->coordinate_y_B = result.coordinate_y_B;		

		call SerialMsgSend.send(AM_BROADCAST_ADDR, &serialMsg, sizeof(Result_t));
	}

	void sendBeaconRecToSerial(BeaconRec_t beaconRec){
		BeaconRec_t* beaconRecToSend;

		beaconRecToSend = (BeaconRec_t*) (call SerialPacket.getPayload(&serialMsg2, sizeof(beaconRecToSend)));

		beaconRecToSend->idAnchor = beaconRec.idAnchor;
		beaconRecToSend->timestamp = beaconRec.timestamp;
		beaconRecToSend->rssi = beaconRec.rssi;
		beaconRecToSend->coordinate_x = beaconRec.coordinate_x;
		beaconRecToSend->coordinate_y = beaconRec.coordinate_y;

		call SerialBeaconRecSend.send(AM_BROADCAST_ADDR, &serialMsg2, sizeof(BeaconRec_t));
	}

	//task per il calcolo della posizione del Blind
   	task void calcPosTask(){
   		Result_t result;

		call Leds.led2On(); //notifico inizio calcolo della posizione

		iterAlgo++;
		result.iterazione = iterAlgo;

		result.timestamp_inizio_A = call LocalTime.get();
		AlgoA();
		result.timestamp_fine_A = call LocalTime.get();

		result.coordinate_x_A = posBlindA.coordinate_x;
		result.coordinate_y_A = posBlindA.coordinate_y;

		result.timestamp_inizio_B = call LocalTime.get();
		AlgoB();
		result.timestamp_fine_B = call LocalTime.get();

		result.coordinate_x_B = posBlindB.coordinate_x;
		result.coordinate_y_B = posBlindB.coordinate_y;
		
		sendToSerial(result);

		call Leds.led2Off(); //notifico fine calcolo della posizione
   	}

   	void AlgoA(){
		//To Do
   	}

   	void AlgoB(){
		//To Do
   	}
}