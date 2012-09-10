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
	
#if 0
	self.hSlider.colors = @[
		UIColor.redColor,
		UIColor.yellowColor,
		UIColor.greenColor,
		UIColor.cyanColor,
		UIColor.blueColor,
		UIColor.magentaColor,
		UIColor.redColor,
	];
	
	self.sSlider.colors = @[
		UIColor.whiteColor,
		UIColor.redColor,
	];
	
	self.bSlider.colors = @[
		UIColor.blackColor,
		UIColor.redColor,
	];
#endif
	
	self.hSlider.value = 0.5f;
	self.sSlider.value = 1.0f;
	self.bSlider.value = 1.0f;
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
	float h = self.hSlider.value;
	float s = self.sSlider.value;
	float b = self.bSlider.value;

	self.hSlider.colors = @[
		[UIColor colorWithHue:0.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:1.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:2.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:3.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:4.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:5.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:6.0f / 6.0f saturation:s brightness:b alpha:1.0f],
	];
	
	self.sSlider.colors = @[
		[UIColor colorWithHue:h saturation:0.0f brightness:b alpha:1.0f],
		[UIColor colorWithHue:h saturation:1.0f brightness:b alpha:1.0f],
	];
	
	self.bSlider.colors = @[
		[UIColor colorWithHue:h saturation:s brightness:0.0f alpha:1.0f],
		[UIColor colorWithHue:h saturation:s brightness:1.0f alpha:1.0f],
	];

	UIColor* color = [UIColor colorWithHue:h saturation:s brightness:b alpha:1.0f];

#if 1
	float colorf[3];
	
	[color getRed:&colorf[0] green:&colorf[1] blue:&colorf[2] alpha:NULL];
	
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
	
	message.r = colorb[0];
	message.g = colorb[1];
	message.b = colorb[2];
	
	message.header.checksum = RGBStripCalcChecksum(&message);
	
	NSData* data = RGBStripMessageToNSData(&message);
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
#endif
}

@end
