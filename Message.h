#pragma once

namespace RGBStrip {
	
	class Message {
	public:
		static const uint16_t MaxLength = 520;

		static const uint8_t Identifier = 0x42;
		
		struct Header {
			uint8_t identifier;
			uint8_t type;

			uint16_t checksum;
			uint16_t length;
			uint16_t code;	
		};
		
	public:
		Header header;
		unsigned char data[0];
		
	public:
		uint16_t calcChecksum() const {
			const uint16_t length = header.length - sizeof(header);
			
			uint16_t checksum = header.type;
			for(uint16_t index = 0; index < length; ++index)
			{
				checksum += data[index];
			}
			
			return checksum;
		}
		
		void fillChecksum()
		{
			header.checksum = calcChecksum();
		}
		
		bool validateChecksum() const
		{
			if(header.identifier != Identifier)
			{
				return false;
			}

			if(header.checksum != calcChecksum())
			{
				return false;
			}
			
			return true;
		}
	};
}
