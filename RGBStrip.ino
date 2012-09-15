#include <SPI.h>

#include "Settings.h"

#include <Ethernet.h>
#include <EthernetUdp.h>
#include <EthernetBonjour.h>
#include <LPD8806.h>

#if defined(USE_DHCP) && (USE_DHCP > 0)
#include <EthernetDHCP.h>
#endif

#include "ColorMessage.h"
#include "ColorArrayMessage.h"

#include "HSBColor.h"
#include "Gamma.h"

EthernetUDP socket;

char messageData[RGBStrip::Message::MaxLength];

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
  int index = 0;
  {
    int length = snprintf(txtRecord+index+1, sizeof(txtRecord)-(index+1), "leds=%u", LedStripLedCount);
    txtRecord[index] = length;
    index += 1 + length;
  }


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
    
    const RGBStrip::Message& message = *(RGBStrip::Message*)messageData;
    
    if(!message.validateChecksum())
    {

    }
    else
    {
      switch(message.header.type) {
        case RGBStrip::ColorMessage::Type :

          void handleMessage(const RGBStrip::ColorMessage& message);
          handleMessage((const RGBStrip::ColorMessage&)message);
          break;

        case RGBStrip::ColorArrayMessage::Type :

          void handleMessage(const RGBStrip::ColorArrayMessage& message);
          handleMessage((const RGBStrip::ColorArrayMessage&)message);
          break;

        default :

          break;
      }
    }
  }
    
  delay(1);
}

void handleMessage(const RGBStrip::ColorMessage& message) {
  int offset = message.offset;
  int count = message.count;
  if(count > ledStrip.numPixels() - offset) {
    count = ledStrip.numPixels() - offset;
  }
  
  RGBColor rgbColor = HSBColor(message.color.h, message.color.s, message.color.b);
  
  for(int i = 0; i <= count; ++i) {
    ledStrip.setPixelColor(offset + i, GammaCorretion(rgbColor.r), GammaCorretion(rgbColor.g), GammaCorretion(rgbColor.b));
  }
  ledStrip.show();
}

void handleMessage(const RGBStrip::ColorArrayMessage& message) {
  int offset = message.offset;
  int count = message.count;
  if(count > ledStrip.numPixels() - offset) {
    count = ledStrip.numPixels() - offset;
  }
  
  for(int i = 0; i <= count; ++i) {
    RGBColor rgbColor = HSBColor(message.colors[i].h, message.colors[i].s, message.colors[i].b);

    ledStrip.setPixelColor(offset + i, GammaCorretion(rgbColor.r), GammaCorretion(rgbColor.g), GammaCorretion(rgbColor.b));
  }
  ledStrip.show();
}

