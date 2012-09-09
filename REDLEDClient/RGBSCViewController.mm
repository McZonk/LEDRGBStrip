//
//  RGBSCViewController.m
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCViewController.h"

#import "MCUDPSocket.h"

#import "RGBStrip.h"

@interface RGBSCViewController () <NSStreamDelegate>

@property (nonatomic, strong) MCUDPSocket* socket;

@end

@implementation RGBSCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)bindToAddress:(NSData*)address
{
	self.socket = [[MCUDPSocket alloc] initWithAddress:address];
}

- (IBAction)sliderChanged:(id)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	float colorf[3];
	
	colorf[0] = self.rSlider.value;
	colorf[1] = self.gSlider.value;
	colorf[2] = self.bSlider.value;
	
	unsigned char colorb[3];
	
	for(NSUInteger i = 0; i < 3; ++i)
	{
		colorb[i] = (unsigned char)(colorf[i] * 255.0f);
		if(colorb[i] < 2)
		{
			colorb[i] = 2;
		}
	}
	
	//NSLog(@"%02x %02x %02x", colorb[0], colorb[1], colorb[2]);
	
	struct RGBStripMessageSetAll message;
	message.header.identifier = RGBStripMessageIdentifier;
	message.header.type = RGBStripMessageTypeSetAll;
	message.header.length = sizeof(message);
	
	message.r = colorb[0] >> 1;
	message.g = colorb[1] >> 1;
	message.b = colorb[2] >> 1;
	
	message.header.checksum = RGBStripCalcChecksum(&message);
	
	NSData* data = RGBStripMessageToNSData(&message);
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
}

@end
