#ifndef RESULT_H__
#define RESULT_H__

enum {
	AM_RESULT_T = 8
};

typedef nx_struct Result_t{
	nx_uint16_t iterazione;
	nx_uint8_t id_algoritmo;
	nx_uint8_t state_algoritmo;
	nx_uint32_t timestamp;
	nx_uint16_t coordinate_x;
	nx_uint16_t coordinate_y;
} Result_t;

#endif //RESULT_H__