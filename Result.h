#ifndef RESULT_H__
#define RESULT_H__

enum {
	AM_RESULT_T = 8
};

typedef nx_struct Result_t{
	nx_uint16_t iterazione;
	nx_uint32_t timestamp_inizio_A;
	nx_uint32_t timestamp_fine_A;
	nx_uint16_t coordinate_x_A;
	nx_uint16_t coordinate_y_A;			
	nx_uint32_t timestamp_inizio_B;
	nx_uint32_t timestamp_fine_B;
	nx_uint16_t coordinate_x_B;
	nx_uint16_t coordinate_y_B;	
} Result_t;

#endif //RESULT_H__