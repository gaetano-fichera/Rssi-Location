#include "ApplicationDefinitions.h"
#include "BeaconMessage.h"

module AnchorC {
	uses interface Boot;
	uses interface Packet;
	uses interface Timer<TMilli> as SendTimer;
	uses interface AMSend as BeaconMsgSend;
	uses interface SplitControl as RadioControl;
	uses interface Leds;

} implementation {
	message_t msg;

	//all'avvio si esegue l'avvio di RadioControl
	event void Boot.booted(){		
		call RadioControl.start();
	}

	//all'avvio di RadioControl si esegue l'avvio del Timer ogni SEND_INTERVAL_MS
	event void RadioControl.startDone(error_t result){
		call SendTimer.startPeriodic(SEND_INTERVAL_MS);
	}

	//il Timer scandisce l'invio di Msg in Broadcast
	event void SendTimer.fired(){
		Beacon_msg* beaconMsg = (Beacon_msg*) (call Packet.getPayload(&msg, sizeof(Beacon_msg)));

		beaconMsg->anchor_id = ANCHOR_ID;
		beaconMsg->coordinate_x = COORDINATE_X;
		beaconMsg->coordinate_y = COORDINATE_Y;
		beaconMsg->beacon_period = SEND_INTERVAL_MS;

		call BeaconMsgSend.send(AM_BROADCAST_ADDR, &msg, sizeof(Beacon_msg));
	}

	event void BeaconMsgSend.sendDone(message_t *m,error_t error){
		call Leds.led0Toggle();
		call Leds.led1Toggle();
		call Leds.led2Toggle();
	}

	event void RadioControl.stopDone(error_t result){}
}