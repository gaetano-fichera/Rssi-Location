#include "BeaconMessage.h"

configuration AnchorAppC {
} implementation {
	components MainC, ActiveMessageC, LedsC;
	components new AMReceiverC
	components new AMSenderC(AM_RSSIMSG) as BeaconMsgSender;
	components CC2420ActiveMessageC;

	components BlindC as App;

	components ActiveMessageC, MainC, LedsC;
	components new AMSenderC(AM_RSSIMSG) as BeaconMsgSender;
	components new TimerMilliC() as SendTimer;
	components AnchorC as App;

	App.Boot -> MainC;
	App.SendTimer -> SendTimer;
	App.BeaconMsgSend -> BeaconMsgSender;
	App.RadioControl -> ActiveMessageC;
	App.Packet -> ActiveMessageC;
	App.Leds -> LedsC;
}