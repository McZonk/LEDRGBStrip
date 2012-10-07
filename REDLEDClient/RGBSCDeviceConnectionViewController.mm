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

#import "ColorListMessage.h"


@interface RGBSCDeviceConnectionViewController () <NSNetServiceDelegate>

@property (nonatomic, strong, readwrite) NSNetService* service;
@property (nonatomic, strong, readwrite) MCUDPSocket* socket;
@property (nonatomic, assign, readwrite) NSUInteger ledCount;

@end

@implementation RGBSCDeviceConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self registerSocketObservers];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self registerSocketObservers];
	}
	return self;
}

- (void)registerSocketObservers {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
#if 0
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorListMessage::size(7)];
	
	RGBStrip::ColorListMessage& message = *(RGBStrip::ColorListMessage*)data.mutableBytes;
	
	message.fillHeader(7);
	
	message.offset = 0;
	message.count = 7;
	
	message.keys[0].index = 0;
	message.keys[0].color = HSBColor((uint16_t)   0, (uint8_t)255, (uint8_t)255);
	
	message.keys[1].index = (self.ledCount / 6.0);
	message.keys[1].color = HSBColor((uint16_t) 256, (uint8_t)255, (uint8_t)255);
	
	message.keys[2].index = (self.ledCount / 6.0) * 2.0;
	message.keys[2].color = HSBColor((uint16_t) 512, (uint8_t)255, (uint8_t)255);
	
	message.keys[3].index = (self.ledCount / 6.0) * 3.0;
	message.keys[3].color = HSBColor((uint16_t) 768, (uint8_t)255, (uint8_t)255);
	
	message.keys[4].index = (self.ledCount / 6.0) * 4.0;
	message.keys[4].color = HSBColor((uint16_t)1024, (uint8_t)255, (uint8_t)255);
	
	message.keys[5].index = (self.ledCount / 6.0) * 5.0;
	message.keys[5].color = HSBColor((uint16_t)1280, (uint8_t)255, (uint8_t)255);
	
	message.keys[6].index = self.ledCount;
	message.keys[6].color = HSBColor((uint16_t)1536 - 32, (uint8_t)255, (uint8_t)255);
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
#endif
}



#pragma mark - Networking

- (void)sendColorToDevice:(UIColor*)color range:(NSRange)range {
	float hue;
	float saturation;
	float brightness;
	[color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
	
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorMessage::size()];
	
	RGBStrip::ColorMessage& message = *(RGBStrip::ColorMessage*)data.mutableBytes;
	message.fillHeader(10);
	message.offset = range.location;
	message.count = range.length;
	message.color = HSBColor(hue, saturation, brightness);
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
}

- (void)bindToNetService:(NSNetService*)service {
	if (self.service) {
		self.service.delegate = nil;
		[self _closeSocket];
	}
	
	self.service = service;
	self.service.delegate = self;
	
	[self _openSocket];
	
	NSDictionary* txtRecord = [NSNetService dictionaryFromTXTRecordData:self.service.TXTRecordData];
	{
		NSData* ledsData = [txtRecord objectForKey:@"leds"];
		NSString* ledsString = [[NSString alloc] initWithData:ledsData encoding:NSASCIIStringEncoding];
		self.ledCount = ledsString.integerValue;
	}
	
	self.title = [NSString stringWithFormat:@"%@ (%d)", self.service.name, self.ledCount];
}

- (void)_closeSocket {
	self.socket = nil; //socket will close the connection on dealloc!
}

- (void)_openSocket {
	NSData* address = [self.service.addresses objectAtIndex:0];
	self.socket = [[MCUDPSocket alloc] initWithAddress:address];
}



#pragma mark - Observers

- (void)applicationDidEnterBackground:(NSNotification*)aNotification {
	[self _closeSocket];
}

- (void)applicationWillEnterForeground:(NSNotification*)aNotification {
	[self _openSocket];
}

@end
