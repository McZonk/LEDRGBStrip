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
#include "ColorListMessage.h"

#include "HSBColor.h"
#include "Gamma.h"

EthernetUDP socket;

LPD8806 ledStrip = LPD8806(LedStripLedCount, LedStripDataPin, LedStripClockPin);


void setup()
{
  Serial.begin(9600);
  
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
  
  int messageLength = socket.parsePacket();
  if(messageLength > 0) {
    RGBStrip::Message::Header header;
    
    socket.readBytes((char*)&header, sizeof(header));
    
    if(messageLength == header.length) {
      switch(header.type) {
        case RGBStrip::ColorMessage::Type :

          void handleColorMessage(Stream& stream);
          handleColorMessage(socket);
          break;

        case RGBStrip::ColorArrayMessage::Type :

          void handleColorArrayMessage(Stream& stream);
          handleColorArrayMessage(socket);
          break;
          
       case RGBStrip::ColorListMessage::Type :
       
         Serial.println("ColorList");
       
          void handleColorListMessage(Stream& stream);
          handleColorListMessage(socket);
          break;

        default :

          break;
      }
    }

    // empty the buffer    
    while(socket.available() > 0) {
      socket.read();
    }
  }
    
  delay(1);
}

void handleColorMessage(Stream& stream) {
  uint16_t offset = 0;
  stream.readBytes((char*)&offset, sizeof(offset));

  uint16_t count = 0;  
  stream.readBytes((char*)&count, sizeof(count));
  
  if(count > ledStrip.numPixels() - offset) {
    count = ledStrip.numPixels() - offset;
  }
  
  HSBColor hsbColor;
  stream.readBytes((char*)&hsbColor, sizeof(hsbColor));
  
  RGBColor rgbColor = hsbColor;
  
  for(int i = 0; i < count; ++i) {
    ledStrip.setPixelColor(offset + i, GammaCorretion(rgbColor.r), GammaCorretion(rgbColor.g), GammaCorretion(rgbColor.b));
  }
  ledStrip.show();
}

void handleColorArrayMessage(Stream& stream) {
  uint16_t offset = 0;
  stream.readBytes((char*)&offset, sizeof(offset));
  
  uint16_t count = 0;
  stream.readBytes((char*)&count, sizeof(count));
  
  if(count > ledStrip.numPixels() - offset) {
    count = ledStrip.numPixels() - offset;
  }
  
  for(int i = 0; i < count; ++i) {
    HSBColor hsbColor;
    stream.readBytes((char*)&hsbColor, sizeof(hsbColor));
    
    RGBColor rgbColor = hsbColor;

    ledStrip.setPixelColor(offset + i, GammaCorretion(rgbColor.r), GammaCorretion(rgbColor.g), GammaCorretion(rgbColor.b));
  }
  ledStrip.show();
}

void handleColorListMessage(Stream& stream) {
  uint16_t offset = 0;
  stream.readBytes((char*)&offset, sizeof(offset));
  
  uint16_t count = 0;
  stream.readBytes((char*)&count, sizeof(count));

  if(count > 0) {
    RGBStrip::ColorListMessage::Key pKey;
    stream.readBytes((char*)&pKey, sizeof(pKey));
  
    Serial.println(pKey.index, DEC);
  
    for(int i = 1; i < count; ++i) {
      RGBStrip::ColorListMessage::Key cKey;
      stream.readBytes((char*)&cKey, sizeof(cKey));
      
      Serial.println(cKey.index, DEC);

      RGBColor rgbColor = pKey.color;
      
      for(int j = pKey.index; j <= cKey.index; ++j) {
        if(offset + j >= LedStripLedCount) {
          break;
        }
        
        ledStrip.setPixelColor(offset + j, GammaCorretion(rgbColor.r), GammaCorretion(rgbColor.g), GammaCorretion(rgbColor.b));
      }
      
      pKey = cKey;
    }
    
    ledStrip.show();
  }
}
