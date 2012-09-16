#pragma once

namespace RGBStrip {
	
	class Message {
	public:
		static const uint8_t Identifier = 0x42;
		
		struct Header {
			uint8_t identifier;
			uint8_t type;

			uint16_t length;
		};
		
	public:
		Header header;
		unsigned char data[0];
	};
}
