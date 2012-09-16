#pragma once

byte mac[] = { 0x90, 0x2A, 0xDA, 0x0D, 0x61, 0x73 };

#define USE_DHCP 1

// Only used if no dhcp
byte ip[] = { 192, 168, 178, 154 };

int port = 1403;

const int LedStripLedCount = 64;
const int LedStripDataPin  = 2;
const int LedStripClockPin = 3;

const char* LocationName = "LivingRoom"; // Must not be longer than 16 bytes
