#pragma once

#include <stdint.h>

#include "RGBColor.h"

#define HSBColorHueRange (1536)

// HSB == HSV, HSB != HSL
// hue is ranged from 0 - 1535 for performance reasons (6 * 256)

class HSBColor {  
public:
	HSBColor();

	HSBColor(int16_t h, uint8_t s, uint8_t b);
	HSBColor(float h, float s, float b);
	
	void normalizeSelf();

	operator RGBColor() const;
	
	friend HSBColor lerp(const HSBColor c0, const HSBColor c1, const int16_t time);

public:
	union {
		struct {
			int16_t h;
			uint8_t s;
			uint8_t b;
		};
		uint32_t value;
	};
};

inline HSBColor::HSBColor() {
}

inline HSBColor::HSBColor(int16_t h, uint8_t s, uint8_t b) :
	h(h),
	s(s),
	b(b) {
}

inline HSBColor::HSBColor(float h, float s, float b) :
	h(h * (HSBColorHueRange - 1.0f)),
	s(s * 255.0f),
	b(b * 255.0f) {
}

inline void HSBColor::normalizeSelf() {
	h %= HSBColorHueRange;
	if(h < 0) {
		h += HSBColorHueRange;
	}
}
