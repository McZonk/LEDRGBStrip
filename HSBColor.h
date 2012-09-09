#pragma once

#include <stdint.h>

#include "RGBColor.h"

#define HSBColorHueRange (1536)

// HSB == HSV, HSB != HSL
// hue is ranged from 0 - 1535 for performance reasons (6 * 256)

class HSBColor {  
public:
  static const HSBColor Red;
  static const HSBColor Yellow;
  static const HSBColor Green;
  static const HSBColor Cyan;
  static const HSBColor Blue;
  static const HSBColor Magenta;

  HSBColor();

  HSBColor(int16_t h, uint8_t s, uint8_t v);
  
  void normalizeSelf();

  operator RGBColor() const;

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

inline void HSBColor::normalizeSelf() {
  h %= HSBColorHueRange;
  if(h < 0) {
    h += HSBColorHueRange;
  }
}

