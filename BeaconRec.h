#ifndef BEACONREC_H__
#define BEACONREC_H__

enum {
	AM_BEACONREC_T = 80
};

typedef nx_struct BeaconRec_t{
	nx_uint16_t idAnchor;
	nx_uint32_t timestamp;
	nx_int8_t rssi;
	nx_uint16_t coordinate_x;
	nx_uint16_t coordinate_y;
} BeaconRec_t;

#endif //BeaconRec_H__