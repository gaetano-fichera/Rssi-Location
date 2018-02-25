#include "BeaconMessage.h"

configuration BlindAppC {
} implementation {
	components MainC, LedsC;
	components ActiveMessageC, SerialActiveMessageC;
	components CC2420PacketC;
	components new AMSenderC(AM_BEACON_MSG) as BeaconMsgSender;
	components new AMReceiverC(AM_BEACON_MSG) as BeaconMsgReceiver;
	components new SerialAMSenderC(AM_BEACON_MSG) as SerialMsgSender;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components BlindC as App;

	App.Boot -> MainC;
  	App.BeaconPacket -> CC2420PacketC;
  	App.RadioControl -> ActiveMessageC;
  	App.SerialControl -> SerialActiveMessageC;
  	App.SerialMsgSend -> SerialMsgSender;
  	App.SerialPacket -> SerialActiveMessageC;
	App.BeaconMsgReceive -> BeaconMsgReceiver;
	App.BeaconMsgSend -> BeaconMsgSender;
	App.CalcPosTimer -> Timer0;
	App.SerialTestTimer -> Timer1;
	App.Leds -> LedsC;

}