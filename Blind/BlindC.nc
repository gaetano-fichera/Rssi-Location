#include "ApplicationDefinitions.h"
#include "BeaconMessage.h"
#include "Pos.h"

module BlindC {
  uses interface Intercept as BeaconMsgIntercept;
  uses interface CC2420Packet;
  uses interface Leds;

} implementation {

  uint16_t getRssi(message_t *msg);
  
  event bool BeaconMsgIntercept.forward(message_t *msg, void *payload, uint8_t len) {
    Beacon_msg *beaconMsg = (Beacon_msg*) payload;
    call Leds.led0Toggle();

    beaconMsg -> beacon_period = getRssi(msg);
        
    return TRUE;
  }

  uint16_t getRssi(message_t *msg){
    return (uint16_t) call CC2420Packet.getRssi(msg);
  }
}