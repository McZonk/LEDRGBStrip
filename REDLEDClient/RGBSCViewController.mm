//
//  RGBSCViewController.m
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCViewController.h"

#import "MCUDPSocket.h"

#import "ColorMessage.h"
#import "ColorArrayMessage.h"

@interface RGBSCViewController () <NSNetServiceDelegate>

@property (nonatomic, strong) NSNetService* netService;
@property (nonatomic, strong) MCUDPSocket* socket;

@property (nonatomic, assign) NSUInteger ledCount;

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
	
	self.firstStepper.maximumValue = self.ledCount;
	[self.firstStepper sendActionsForControlEvents:UIControlEventValueChanged];
	self.lastStepper.maximumValue = self.ledCount;
	[self.lastStepper sendActionsForControlEvents:UIControlEventValueChanged];
	
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

- (void)bindToNetService:(NSNetService*)netService
{
	if(self.netService.delegate == self)
	{
		self.netService.delegate = nil;
	}
	
	self.netService = netService;
	self.netService.delegate = self;
	
	NSData* address = [self.netService.addresses objectAtIndex:0];
	
	self.socket = [[MCUDPSocket alloc] initWithAddress:address];
	
	NSDictionary* txtRecord = [NSNetService dictionaryFromTXTRecordData:self.netService.TXTRecordData];
	
	{
		NSData* ledsData = [txtRecord objectForKey:@"leds"];
		
		NSString* ledsString = [[NSString alloc] initWithData:ledsData encoding:NSASCIIStringEncoding];
		
		self.ledCount = ledsString.integerValue;
		
		NSLog(@"leds: %u", self.ledCount);
	}
	
#if 0
	// Test random colors
	
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorArrayMessage::size(56)];
	
	RGBStrip::ColorArrayMessage& message = *(RGBStrip::ColorArrayMessage*)data.mutableBytes;
	
	message.fillHeader(56);
	
	message.offset = 0;
	message.count = 56;

	for(NSUInteger index = 0; index < 56; ++index)
	{
		message.colors[index] = HSBColor((uint16_t)(rand() % 1536), (uint8_t)(rand() % 255), (uint8_t)(rand() % 256));
	}
	
	message.fillChecksum();
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
#endif
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
	
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorMessage::size()];
	
	RGBStrip::ColorMessage& message = *(RGBStrip::ColorMessage*)data.mutableBytes;

	message.fillHeader();
	
	message.offset = self.firstStepper.value;
	message.count = self.lastStepper.value - self.firstStepper.value;
	
	message.color = HSBColor(h, s, b);
	
	message.fillChecksum();
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
}

- (IBAction)firstLEDChanged:(id)sender
{
	self.firstTextView.text = [NSString stringWithFormat:@"%.0f", self.firstStepper.value];
}

- (IBAction)lastLEDChanged:(id)sender
{
	self.lastTextView.text = [NSString stringWithFormat:@"%.0f", self.lastStepper.value];
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidStop:(NSNetService *)sender
{
//	[self.navigationController popViewControllerAnimated:YES];
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
	
}


@end
