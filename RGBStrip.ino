#include <SPI.h>

#include "Settings.h"

#include <Ethernet.h>
#include <EthernetUdp.h>
#include <EthernetBonjour.h>
#include <LPD8806.h>

#if defined(USE_DHCP) && (USE_DHCP > 0)
#include <EthernetDHCP.h>
#endif

#include "RGBStrip.h"
#include "Gamma.h"

EthernetUDP socket;

char messageData[256];

LPD8806 ledStrip = LPD8806(LedStripLedCount, LedStripDataPin, LedStripClockPin);

void setup()
{  
  ledStrip.begin();

#if defined(USE_DHCP) && (USE_DHCP > 0)
  ledStrip.setPixelColor(0, 16, 0, 0);
  ledStrip.show();

  EthernetDHCP.begin(mac);
  const byte* ip = EthernetDHCP.ipAddress();
#endif
  
  ledStrip.setPixelColor(0, 16, 16, 0);
  ledStrip.show();
  
  Ethernet.begin(mac, ip);
  socket.begin(port);
  
  char serviceName[32];
  snprintf(serviceName, sizeof(serviceName), "%s._rgbled", LocationName);

  char txtRecord[64];
  snprintf(txtRecord, sizeof(txtRecord), "leds=%u", LedStripLedCount);

  EthernetBonjour.begin("arduino");
  EthernetBonjour.addServiceRecord(serviceName, port, MDNSServiceUDP, txtRecord);
  
  ledStrip.setPixelColor(0, 0, 0, 0);
  ledStrip.show();
}

void loop()
{  
#if defined(USE_DHCP) && (USE_DHCP > 0)
  // Maintain DHCP
  EthernetDHCP.maintain();
#endif
  
  // Maintain Bonjour
  EthernetBonjour.run();
  
  int messageSize = socket.parsePacket();
  if(messageSize > sizeof(messageData))
  {
    // oversized packet, read until done
    for(int i = 0; i < messageSize; i += sizeof(messageData))
    {
      socket.read(messageData, sizeof(messageData));
    }
  }
  else if(messageSize > 0)
  {
    socket.read(messageData, messageSize);
    
    RGBStripMessage& message = *(RGBStripMessage*)messageData;
    
    if(!RGBStripValidateMessage(&message))
    {
    }
    else
    {
      switch(message.header.type) {
        case RGBStripMessageTypeSetAll :
          hanleRGBStripMessageSetAll((RGBStripMessageSetAll&)message);
          break;
        default :
          break;
      }
    }
  }
    
  delay(1);
}

void hanleRGBStripMessageSetAll(const RGBStripMessageSetAll& message)
{
  for(int i = 0; i < LedStripLedCount; ++i)
  {
    ledStrip.setPixelColor(i, GammaCorretion(message.r), GammaCorretion(message.g), GammaCorretion(message.b));
  }
  ledStrip.show();
}

