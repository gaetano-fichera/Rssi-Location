#include "BeaconMessage.h"
#include "Pos.h"

configuration BlindAppC {
} implementation {
	components MainC, LedsC;

	components ActiveMessageC as RadioAM;
	components new AMSenderC(AM_BEACON_MSG) as BeaconMsgSender;
	components new AMReceiverC(AM_BEACON_MSG) as BeaconMsgReceiver;
	components CC2420PacketC as TelosBeaconPacket;

	components SerialActiveMessageC as SerialAM;
	components new SerialAMSenderC(AM_POS_T) as SerialMsgSender;

	components new TimerMilliC() as Timer0;

	components BlindC as App;


	App.Boot -> MainC;

  	App.RadioControl -> RadioAM;
	App.BeaconMsgReceive -> BeaconMsgReceiver;
	App.BeaconMsgSend -> BeaconMsgSender;
	App.BeaconPacket -> TelosBeaconPacket;

  	App.SerialControl -> SerialAM;
  	App.SerialMsgSend -> SerialMsgSender;
  	App.SerialPacket -> SerialAM;

	App.CalcPosTimer -> Timer0;
	App.Leds -> LedsC;
}