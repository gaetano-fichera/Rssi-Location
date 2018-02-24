#include "ApplicationDefinitions.h"
#include "BeaconMessage.h"
#include "Pos.h"

module BlindC {
	uses interface Boot;
	uses interface SplitControl as AMControl;
	uses interface Receive as BeaconMsgReceive;
	uses interface AMSendPacket as BeaconMsgSend;
	uses interface CC2420Packet as BeaconMsgPacket;
	uses interface Timer<TMilli> as CalcPosTimer;
	uses interface Leds;

} implementation {
	uint8_t minX, maxX, minY, maxY; //min e max delle coordinate della griglia
	Pos_t posAnchors[MAX_ANCHOR]; //array delle posizioni delle ancore
	bool foundedAnchors[MAX_ANCHOR]; //array di bool per tenere traccia delle ancore trovate a runtime
	uint8_t bufferIndex[MAX_ANCHOR]; //array degli indici relativi al buffer per renderlo circolare
	uint16_t buffer[MAX_ANCHOR][BUFFER_DEPTH]; //matrice buffer degli rssi dei messaggi ricevuti dalle ancore
	bool bufferReady[MAX_ANCHOR]; //ogni elemento diventa true quando il relativo buffer è pieno
	bool calcPosStarted;

	void init();
	uint16_t getRssi(message_t *msg);
	task void handleBeacon(Beacon_msg* beacon_msg, uint16_t rssi);
	void addToBuffer(uint8_t idAnchor, uint16_t rssi);
	void calcMinMaxGrid(Pos_t posAnchor);
	void increaseBufferIndex(uint8_t id);
	bool IsBufferReady();


	event void Boot.booted(){
		init();

		AMControl.start();
	}

	// inizializzazione delle variabili
	void init(){
		//affinchè calcMinMaxGrid funzioni, i min devono essere inizializzati ai valori massimi e i max ai valori minimi
		minX = 255;
		maxX = 0;
		minY = 255;
		maxY = 0;

		for (int i = 0; i < MAX_ANCHOR; ++i){
			foundedAnchors[i] = false;
			bufferIndex[i] = 0;
		}

		calcPosStarted = false;
	}

	event void AMControl.startDone(error_t rr){
		if(err == SUCCESS){
			call Leds.led0Toggle(); //accendo il led0 per indicare il funzionamento del ricevitore
		}else{
			call AMControl.start();
		}
	}

	event message_t* BeaconMsgReceive.receive(message_t* msg, void* payload, uint8_t len) {
		if (len == sizeof(Beacon_msg)) {
			Beacon_msg* beaconMsg = (Beacon_msg*)payload;
			uint16_t rssi = getRssi(msg);

			post handleBeacon(beaconMsg, rssi);//gestisco il beacon ricevuto
  		}
  		return msg;
	}

	//ottengo il valore rssi del messaggio
	uint16_t getRssi(message_t *msg){
		return (uint16_t) call CC2420Packet.getRssi(msg);
  	}

  	//gestione del beacon ricevuto
  	task void handleBeacon(Beacon_msg* beaconMsg, uint16_t rssi){
  		uint8_t idAnchor = beaconMsg->anchor_id;
  		idAnchor = idAnchor - 1; //perchè abbiamo considerato che gli id delle ancore siano numerate da 1 a MAX_ANCHOR

  		if (foundedAnchors[idAnchor] == false){ //aggiungo l'ancora nuova se ancora non l'avevo trovata
	  			Pos_t posAnchor; //creo il pos_t da aggiungere con le coordinate dell'ancora
		  		posAnchor->coordinate_x = beaconMsg->coordinate_x;
		  		posAnchor->coordinate_y = beaconMsg->coordinate_y;
				posAnchors[idAnchor] = posAnchor; //aggiungo il pos_t all'array

  				calcMinMaxGrid(posAnchor); //calcolo gli estremi della griglia

  				foundedAnchors[idAnchor] = true; //imposto di aver trovato l'ancora con lo specifico id
  		}
  		addToBuffer(idAnchor, rssi); //aggiungo il valore rssi del beacon mandato dall'ancora al buffer

  		if (calcPosStarted == false){ //se il processo di calcolo della pos non è stato ancora avviato
  			if (IsBufferReady == true){	//se il buffer è pieno avvio il process di calcolo della pos
  				call Leds.led1Toggle(); //accendo il led1 per indicare l'avvio di calc pos
  				calcPosStarted = true;
  				call CalcPosTimer.startPeriodic(CALC_POS_INTERVAL_MS);
  			}
  		}
  	}

  	//calcolo degli estremi della griglia quadrata
  	void calcMinMaxGrid(Pos_t posAnchor){
  		if (posAnchor->coordinate_x < minX) minX = posAnchor->coordinate_x;
  		if (posAnchor->coordinate_x > maxX) maxX = posAnchor->coordinate_x;
  		if (posAnchor->coordinate_y < minY) minY = posAnchor->coordinate_y;
  		if (posAnchor->coordinate_y > maxY) maxY = posAnchor->coordinate_y;
  	}

  	//aggiorna il buffer degli rssi
  	void addToBuffer(uint8_t idAnchor, uint16_t rssi){
  		int row = idAnchor;
  		int column = bufferIndex[idAnchor];
  		buffer[row][column] = rssi;
  		increaseBufferIndex(idAnchor);
  	}

  	//rende il buffer circolare
  	void increaseBufferIndex(uint8_t id){
  		bufferIndex[id] = bufferIndex[id] + 1;
  		//resetto l'indice del buffer nel caso sia oltre il massimo
  		if (bufferIndex[id] == BUFFER_DEPTH){
  			bufferIndex[id] = 0;
  			bufferReady[id] = true;
  		}
  	}

  	bool IsBufferReady(){
  		for (int i = 0; i < MAX_ANCHOR; ++i){
  			if(bufferReady[i] == false) return false;
  		}
  		return true;
  	}

  	event void CalcPosTimer.fired() {
  		post calcPos();
   	}

   	task void calcPos(){
   		call Leds.led2Toggle();
   	}
}