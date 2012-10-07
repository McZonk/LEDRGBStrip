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
HSBColor targetColors[LedStripLedCount];
uint16_t animationDuration;
uint32_t const updateInterval = 1000/30; //in milliseconds

void setup()
{
  Serial.begin(9600);
  Serial.println("Setup...");
  
  pinMode(8, OUTPUT);
    
  ledStrip.begin();
  
#if defined(USE_DHCP) && (USE_DHCP > 0)
  ledStrip.setPixelColor(0, 16, 0, 0);
  ledStrip.show();

  EthernetDHCP.begin(mac);
  const byte* ip = EthernetDHCP.ipAddress();
  
  Serial.println("DHCP running");
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
  
  Serial.println("NetService running");
  
  animationDuration = 0;
  
  Timer1.initialize(updateInterval * 1000);
  Timer1.attachInterrupt(ledUpdate);
  
  Serial.println("...done!");
}

void loop()
{  
#if defined(USE_DHCP) && (USE_DHCP > 0)
  // Maintain DHCP
  EthernetDHCP.maintain();
#endif
  
  RGBColor color = targetColors[0];
  Serial.print("Color of first LED: r=");
  Serial.print(color.r);
  Serial.print(", g=");
  Serial.print(color.g);
  Serial.print(", b=");
  Serial.println(color.b);
  
  // Maintain Bonjour
  EthernetBonjour.run();
  
  int messageLength = socket.parsePacket();
  if(messageLength > 0) {
    RGBStrip::Message::Header header;
    
    socket.readBytes((char*)&header, sizeof(header));
    
    if(messageLength == header.length) {
      noInterrupts();
      
      animationDuration = header.transitionDuration;
      
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
      
      Serial.println("Message received!");
    }

    // empty the buffer    
    while(socket.available() > 0) {
      socket.read();
    }
  }
    
  delay(1);
}

void ledUpdate() {
  digitalWrite(8, digitalRead(8) ^ 1);
  for(int i = 0; i < LedStripLedCount; ++i) {
    HSBColor currentColor;
    if (animationDuration == 0) {
      currentColor = targetColors[i];
    } else {
      currentColor = lerp(currentColors[i], targetColors[i], ((float)updateInterval / (float)animationDuration) * 256);
    }
    
    currentColors[i] = currentColor;
     
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
    targetColors[offset + i] = color;
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
    
    targetColors[offset + i] = color;
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

        targetColors[offset + j] = color;
      }
      
      pKey = cKey;
    }
  }
}
