#include "ApplicationDefinitions.h"
#include "BeaconMessage.h"
#include "Pos.h"

module BlindC {
	uses interface Boot;
	uses interface SplitControl as AMControl;
	uses interface Receive as BeaconMsgReceive;
	uses interface AMSendPacket as BeaconMsgSend;
	uses interface CC2420Packet as BeaconMsgPacket;
	uses interface Timer<TMilli> as Timer;
	uses interface Leds;

} implementation {
	uint8_t minX, maxX, minY, maxY, anchorFounded;
	Pos_t posAnchors[MAX_ANCHOR];
	bool foundedAnchors[MAX_ANCHOR];
	uint8_t buffer_len[MAX_ANCHOR];
	uint16_t[MAX_ANCHOR][BUFFER_DEPTH];

	void init();
	uint16_t getRssi(message_t *msg);
	task void handleBeacon(Beacon_msg* beacon_msg, uint16_t rssi);
	void handleNewAnchor(uint8_t idAnchor, Pos_t anchor);
	void addToBuffer(uint8_t idAnchor, uint16_t rssi);
	void calcMinMaxGrid(Pos_t posAnchor);

	event void Boot.booted(){
		init();

		AMControl.start();
	}

	void init(){
		//affinchè calcMinMaxGrid funzioni, i min devono essere inizializzati ai valori massimi e i max ai valori minimi
		minX = 255;
		maxX = 0;
		minY = 255;
		maxY = 0;

		anchorFounded = 0;

		int i;
		for (int i = 0; i < MAX_ANCHOR; ++i){
			foundedAnchors[i] = false;
			buffer_len[i] = 0;
		}
	}

	event void AMControl.startDone(error_t rr){
		if(err == SUCCESS){
			call Leds.led0Toggle(); //lasciare acceso;
		}else{
			call AMControl.start();
		}
	}

	event message_t* BeaconMsgReceive.receive(message_t* msg, void* payload, uint8_t len) {
		if (len == sizeof(Beacon_msg)) {
			Beacon_msg* beaconMsg = (Beacon_msg*)payload;
			uint16_t rssi = getRssi(msg);

			post handleBeacon(beaconMsg, rssi);
  		}
  		return msg;
	}

	uint16_t getRssi(message_t *msg){
		return (uint16_t) call CC2420Packet.getRssi(msg);
  	}

  	task void handleBeacon(Beacon_msg* beaconMsg, uint16_t rssi){
  		uint8_t idAnchor = beaconMsg->anchor_id;
  		if (anchorFounded < MAX_ANCHOR)	//aggiorno array delle posizioni delle ancore
  		{
  			Pos_t posAnchor;
	  		posAnchor->coordinate_x = beaconMsg->coordinate_x;
	  		posAnchor->coordinate_y = beaconMsg->coordinate_y;

	  		handleNewAnchor(idAnchor, posAnchor);

	  		anchorFounded++;
  		}
  		addToBuffer(idAnchor, rssi);
  	}

  	void handleNewAnchor(uint8_t idAnchor, Pos_t posAnchor){
  		if (foundedAnchors[idAnchor] == false)
  		{
  			posAnchors[idAnchor] = posAnchor;
  			calcMinMaxGrid(posAnchor);
  			foundedAnchors[idAnchor] = true;
  		}
  	}

  	void calcMinMaxGrid(Pos_t posAnchor){
  		if (posAnchor->coordinate_x < minX) minX = posAnchor->coordinate_x;
  		if (posAnchor->coordinate_x > maxX) maxX = posAnchor->coordinate_x;
  		if (posAnchor->coordinate_y < minY) minY = posAnchor->coordinate_y;
  		if (posAnchor->coordinate_y > maxY) maxY = posAnchor->coordinate_y;
  	}

  	void addToBuffer(uint8_t idAnchor, uint16_t rssi){

  	}
}