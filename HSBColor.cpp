#include "HSBColor.h"

const HSBColor HSBColor::Red(0, 255, 255);
const HSBColor HSBColor::Yellow(256, 255, 255);
const HSBColor HSBColor::Green(512, 255, 255);
const HSBColor HSBColor::Cyan(768, 255, 255);
const HSBColor HSBColor::Blue(1024, 255, 255);
const HSBColor HSBColor::Magenta(1280, 255, 255);


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
