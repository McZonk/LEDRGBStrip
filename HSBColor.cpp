#include "HSBColor.h"

HSBColor::operator RGBColor() const {
	const uint8_t hh = h >> 8;
	const uint8_t lh = h & 0xff;
  
	RGBColor color;
	switch(hh) {
		case 0:
			color.r = 255;
			color.g = lh;
			color.b = 0;
			break;
		case 1:
			color.r = 255 - lh;
			color.g = 255;
			color.b = 0;
			break;
		case 2:
			color.r = 0;
			color.g = 255;
			color.b = lh;
			break;
		case 3:
			color.r = 0;
			color.g = 255 - lh;
			color.b = 255;
			break;
		case 4:
			color.r = lh;
			color.g = 0;
			color.b = 255;
			break;
		default:
			color.r = 255;
			color.g = 0;
			color.b = 255 - lh;
			break;
	}
  
	const uint16_t saturation1 = s + 1;
  
	color.r = 255 - (((255 - color.r) * saturation1) >> 8);
	color.g = 255 - (((255 - color.g) * saturation1) >> 8);
	color.b = 255 - (((255 - color.b) * saturation1) >> 8);
  
	const uint16_t brightness1 = b + 1;
  
	color.r = (color.r * brightness1) >> 8;
	color.g = (color.g * brightness1) >> 8;
	color.b = (color.b * brightness1) >> 8;
  
	return color;
}

HSBColor lerp(const HSBColor c0, const HSBColor c1, int16_t time) {
	if(time < 0) {
		time = 0;
	} else if(time > 256) {
		time = 256;
	}
	
	// a + (b - a) * t
	
	HSBColor r;
	
	r.h = c0.h + ((((int32_t)c1.h - (int32_t)c0.h) * time) >> 8);
	r.s = c0.s + ((((int16_t)c1.s - (int16_t)c0.s) * time) >> 8);
	r.b = c0.b + ((((int16_t)c1.b - (int16_t)c0.b) * time) >> 8);
	
	return r;
}
