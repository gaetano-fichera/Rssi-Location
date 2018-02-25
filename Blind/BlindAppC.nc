#include "BeaconMessage.h"
#include "Pos.h"
#include "message.h"

configuration BlindAppC {
} implementation {
  components BaseStationC, LedsC;
  components BlindC as App;
  components CC2420ActiveMessageC;
  
  App -> CC2420ActiveMessageC.CC2420Packet;
  App -> BaseStationC.RadioIntercept[AM_BEACON_MSG];
  App.Leds -> LedsC;
}