#ifndef POST_H__
#define POST_H__

enum {
	AM_POS_T = 9
};

typedef nx_struct Pos_t{
	nx_uint16_t coordinate_x;
	nx_uint16_t coordinate_y;
} Pos_t;

#endif //POST_H__