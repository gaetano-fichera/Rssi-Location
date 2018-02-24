#include "BeaconMessage.h"

configuration BlindAppC {
} implementation {
	components MainC, LedsC;
	components ActiveMessageC;
	components CC2420PacketC;
	components new AMSenderC(AM_BEACON) as BeaconMsgSender;
	components new AMReceiverC(AM_BEACON) as BeaconMsgReceiver;
	components new TimerMilliC() as Timer0;
	components BlindC as App;

	App.Boot -> MainC;
  	App.BeaconPacket -> CC2420PacketC;
  	App.AMControl -> ActiveMessageC;
	App.BeaconMsgReceive -> BeaconMsgReceiver;
	App.BeaconMsgSend -> BeaconMsgSender;
	App.CalcPosTimer -> Timer0;
	App.Leds -> LedsC;

}