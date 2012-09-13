#pragma once

#include <stdint.h>

class RGBColor {
public:
	RGBColor();
	RGBColor(uint8_t r, uint8_t g, uint8_t b);

public:
	union {
		struct {
			uint8_t r;
			uint8_t g;
			uint8_t b;
			uint8_t a;
		};
		uint8_t array[4];
		uint32_t value;
	};
};

inline RGBColor::RGBColor() {
}

inline RGBColor::RGBColor(uint8_t r, uint8_t g, uint8_t b) :
	r(r),
	g(g),
	b(b) {
}
