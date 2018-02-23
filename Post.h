#ifndef POST_H__
#define POST_H__

enum {
	AM_RSSIMSG = 10
};

typedef nx_struct Pos_t{
	nx_uint16_t coordinate_x;
	nx_uint16_t coordinate_y;

} RssiMsg;

#endif //POST_H__