//
//  RGBSCDeviceConnectionViewController.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/23/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCDeviceConnectionViewController.h"

#import "ColorMessage.h"
#import "MCUDPSocket.h"


@interface RGBSCDeviceConnectionViewController () <NSNetServiceDelegate>

@property (nonatomic, strong, readwrite) NSNetService* service;
@property (nonatomic, strong, readwrite) MCUDPSocket* socket;
@property (nonatomic, assign, readwrite) NSUInteger ledCount;

@end

@implementation RGBSCDeviceConnectionViewController

#pragma mark - Networking

- (void)sendColorToDevice:(UIColor*)color range:(NSRange)range {
	float hue;
	float saturation;
	float brightness;
	[color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
	
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorMessage::size()];
	
	RGBStrip::ColorMessage& message = *(RGBStrip::ColorMessage*)data.mutableBytes;
	message.fillHeader();
	message.offset = range.location;
	message.count = range.length;
	message.color = HSBColor(hue, saturation, brightness);
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
}

- (void)bindToNetService:(NSNetService*)service {
	self.service.delegate = nil;
	
	self.service = service;
	self.service.delegate = self;
	
	NSData* address = [self.service.addresses objectAtIndex:0];
	self.socket = [[MCUDPSocket alloc] initWithAddress:address];
	
	NSDictionary* txtRecord = [NSNetService dictionaryFromTXTRecordData:self.service.TXTRecordData];
	{
		NSData* ledsData = [txtRecord objectForKey:@"leds"];
		NSString* ledsString = [[NSString alloc] initWithData:ledsData encoding:NSASCIIStringEncoding];
		self.ledCount = ledsString.integerValue;
	}
	
	self.title = [NSString stringWithFormat:@"%@ (%d)", self.service.name, self.ledCount];
}

@end
