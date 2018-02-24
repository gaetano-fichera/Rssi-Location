#include "ApplicationDefinitions.h"
#include "BeaconMessage.h"
#include "Post.h"

module BlindC {
  uses interface Intercept as BeaconMsgIntercept;
  uses interface CC2420Packet;
  uses interface Leds;

} implementation {

  Pos_t pos_archors[MAX_ANCHOR];

  uint16_t getRssi(message_t *msg);
  
  event bool BeaconMsgIntercept.forward(message_t *msg, void *payload, uint8_t len) {
    Beacon_msg *beaconMsg = (Beacon_msg*) payload;
    beaconMsg->rssi = getRssi(msg);
    call Leds.led0Toggle();
        
    return TRUE;
  }

  uint16_t getRssi(message_t *msg){
    return (uint16_t) call CC2420Packet.getRssi(msg);
  }

  task void updatePosAnchors(Beacon_msg beacon_msg){
    int i;
    for(i = 0; i < MAX_ANCHOR; i++){
      
    }
  }
}