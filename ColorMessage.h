#pragma once

#include "Message.h"

#include "HSBColor.h"

namespace RGBStrip {

	class ColorMessage : public Message {
	public:
		static const uint8_t Type = 0x01;
		
		static uint16_t size() {
			return sizeof(ColorMessage);
		}
		
	public:
		uint16_t offset;
		uint16_t count;
		
		HSBColor color;
		
		void fillHeader() {
			header.identifier = Identifier;
			header.type = Type;
			header.length = size();
		}
	};
	
}
