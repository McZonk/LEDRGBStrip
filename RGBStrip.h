#pragma once

#define RGBStripMessageIdentifier 0x42

#define RGBStripMessageTypeSetRange 0x01

struct RGBStripMessageHeader
{
	uint8_t identifier;
	uint8_t length;
	uint8_t checksum;
	uint8_t type;
};

struct RGBStripMessage
{
	RGBStripMessageHeader header;
	uint8_t data[0];
	
	uint8_t calcChecksum() const
	{
		const unsigned char length = header.length - sizeof(header);
		
		unsigned char checksum = header.type;
		for(unsigned char index = 0; index < length; ++index)
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
		if(header.identifier != RGBStripMessageIdentifier)
		{
			return false;
		}
		
		unsigned char checksum = calcChecksum();
		if(header.checksum != checksum)
		{
			return false;
		}
		
		return true;
	}
	
#ifdef __OBJC__
	operator NSData* () const
	{
		return [NSData dataWithBytes:this length:header.length];
	}
#endif
};

struct RGBStripMessageSetRange : RGBStripMessage
{
	uint16_t firstLED;
	uint16_t lastLED;

	int16_t hue;
	uint8_t saturation;
	uint8_t brightness;

	uint8_t animation;
	
	RGBStripMessageSetRange()
	{
		header.identifier = RGBStripMessageIdentifier;
		header.type = RGBStripMessageTypeSetRange;
		header.length = sizeof(*this);
	}
};

