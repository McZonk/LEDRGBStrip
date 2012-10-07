#pragma once

#include "Message.h"

#include "HSBColor.h"

namespace RGBStrip {
	
	class ColorArrayMessage : public Message {
	public:
		static const uint8_t Type = 0x02;

		static uint16_t size(uint16_t count) {
			return sizeof(ColorArrayMessage) + sizeof(HSBColor) * count;
		}
		
	public:
		uint16_t offset;
		uint16_t count;
		
		HSBColor colors[0];
		
		void fillHeader(uint16_t count, uint16_t transitionDuration = 0) {
			header.identifier = Identifier;
			header.type = Type;
			header.transitionDuration = transitionDuration;
			header.length = size(count);
		}
	};
	
}
