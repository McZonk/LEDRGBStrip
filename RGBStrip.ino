#include <SPI.h>

#include "Settings.h"

#include <Ethernet.h>
#include <EthernetUdp.h>
#include <EthernetBonjour.h>
#include <LPD8806.h>
#include <TimerOne.h>

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

HSBColor currentColors[LedStripLedCount];
//HSBColor targetColors[LedStripLedCount];

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
  
  Timer1.initialize(1000000 / 30);
  Timer1.attachInterrupt(ledUpdate);
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
      noInterrupts();
      
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
       
          void handleColorListMessage(Stream& stream);
          handleColorListMessage(socket);
          break;

        default :

          break;
      }
      
      interrupts();
    }

    // empty the buffer    
    while(socket.available() > 0) {
      socket.read();
    }
  }
    
  delay(1);
}

void ledUpdate() {
  static int animation = 0;
  animation += 1;
  animation %= LedStripLedCount;
  
  for(int i = 0; i < 56; ++i) {
    HSBColor currentColor = currentColors[i];
    
    if(animation == i) {
      currentColor.b = (currentColor.b * 256) >> 8;
    } else if((animation+1)%LedStripLedCount == i || (animation+LedStripLedCount-1)%LedStripLedCount == i) {
      currentColor.b = (currentColor.b * 192) >> 8;
    } else if((animation+2)%LedStripLedCount == i || (animation+LedStripLedCount-2)%LedStripLedCount == i) {
      currentColor.b = (currentColor.b * 128) >> 8;
    } else if((animation+3)%LedStripLedCount == i || (animation+LedStripLedCount-3)%LedStripLedCount == i) {
      currentColor.b = (currentColor.b * 64) >> 8;
    } else {
      currentColor.b = 0;
    }
    
    RGBColor rgbColor = currentColor;
    
    ledStrip.setPixelColor(i, GammaCorretion(rgbColor.r), GammaCorretion(rgbColor.g), GammaCorretion(rgbColor.b));
  }
  ledStrip.show();
}

void handleColorMessage(Stream& stream) {
  uint16_t offset = 0;
  stream.readBytes((char*)&offset, sizeof(offset));

  uint16_t count = 0;  
  stream.readBytes((char*)&count, sizeof(count));
  
  if(count > ledStrip.numPixels() - offset) {
    count = ledStrip.numPixels() - offset;
  }
  
  HSBColor color;
  stream.readBytes((char*)&color, sizeof(color));
  
  for(int i = 0; i < count; ++i) {
    currentColors[offset + i] = color;
  }
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
    HSBColor color;
    stream.readBytes((char*)&color, sizeof(color));
    
    currentColors[offset + i] = color;
  }
}

void handleColorListMessage(Stream& stream) {
  uint16_t offset = 0;
  stream.readBytes((char*)&offset, sizeof(offset));
  
  uint16_t count = 0;
  stream.readBytes((char*)&count, sizeof(count));

  if(count > 0) {
    RGBStrip::ColorListMessage::Key pKey;
    stream.readBytes((char*)&pKey, sizeof(pKey));
  
    for(int i = 1; i < count; ++i) {
      RGBStrip::ColorListMessage::Key cKey;
      stream.readBytes((char*)&cKey, sizeof(cKey));
      
      int stepCount = cKey.index - pKey.index;
      int stepIndex = 0;
      
      for(int j = pKey.index; j <= cKey.index; ++j, ++stepIndex) {
        if(offset + j >= LedStripLedCount) {
          break;
        }
        
        int time = ((stepIndex << 8) / stepCount);
        
        HSBColor color = lerp(pKey.color, cKey.color, time);

        currentColors[offset + j] = color;
      }
      
      pKey = cKey;
    }
  }
}
