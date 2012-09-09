#pragma once

#define RGBStripMessageIdentifier 0x42

#define RGBStripMessageTypeSetAll 0x01

struct RGBStripMessageHeader
{
	unsigned char identifier;
	unsigned char length;
	unsigned char checksum;
	unsigned char type;
};

struct RGBStripMessage
{
	RGBStripMessageHeader header;
	unsigned char data[0];
};

struct RGBStripMessageSetAll : RGBStripMessage
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
};


static unsigned char RGBStripCalcChecksum(const RGBStripMessage* message)
{
	const unsigned char length = message->header.length - sizeof(message->header);
	
	unsigned char checksum = message->header.type;
	for(unsigned char index = 0; index < length; ++index)
	{
		checksum += message->data[index];
	}
	
	return checksum;
}

static bool RGBStripValidateMessage(const RGBStripMessage* message)
{
	if(message->header.identifier != RGBStripMessageIdentifier)
	{
		return false;
	}
	
	unsigned char checksum = RGBStripCalcChecksum(message);
	if(message->header.checksum != checksum)
	{
		return false;
	}
	
	return true;
};

#ifdef __OBJC__

static NSData* RGBStripMessageToNSData(const RGBStripMessage* message)
{
	return [NSData dataWithBytes:message length:message->header.length];
}

#endif
