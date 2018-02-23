#include "BeaconMessage.h"

configuration AnchorAppC {
} implementation {
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