//
//  RGBSCBonjourServiceCell.m
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCBonjourServiceCell.h"

static void* const RGBSCBonjourServiceCellKVOContextBonjourService = (void*)&RGBSCBonjourServiceCellKVOContextBonjourService;

@implementation RGBSCBonjourServiceCell

- (id)initWithCoder:(NSCoder*)coder
{
	self = [super initWithCoder:coder];
	if(self != nil)
	{
		[self addObserver:self forKeyPath:@"bonjourService" options:0 context:RGBSCBonjourServiceCellKVOContextBonjourService];
	}
	return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"bonjourService"];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
	if(context == RGBSCBonjourServiceCellKVOContextBonjourService)
	{
		[self updateView];
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)updateView
{
	NSDictionary* txtRecord = [NSNetService dictionaryFromTXTRecordData:self.bonjourService.TXTRecordData];
	
#if 0
	for(NSString* key in txtRecord)
	{
		NSData* data = [txtRecord objectForKey:key];
		
		NSString* value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		
		NSLog(@"%@ = %@", key, value);
	}
#endif
	
	NSData* ledsData = [txtRecord objectForKey:@"leds"];
	NSString* ledsString = [[NSString alloc] initWithData:ledsData encoding:NSASCIIStringEncoding];
	
	self.textLabel.text = self.bonjourService.name;
	
	self.detailTextLabel.text = ledsString;
	
}

@end
