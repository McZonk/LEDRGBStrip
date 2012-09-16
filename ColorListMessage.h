#pragma once

#include "Message.h"

#include "HSBColor.h"

namespace RGBStrip {
	
	class ColorListMessage : public Message {
	public:
		static const uint8_t Type = 0x03;
		
		struct Key{
			HSBColor color __attribute__((packed));
			uint16_t index __attribute__((packed));
		};
		
		static uint16_t size(uint16_t count) {
			return sizeof(ColorListMessage) + sizeof(Key) * count;
		}
		
	public:
		uint16_t offset;
		uint16_t count;

		Key keys[0];
		
		void fillHeader(uint16_t count) {
			header.identifier = Identifier;
			header.type = Type;
			header.length = size(count);
		}
	};
	
}
