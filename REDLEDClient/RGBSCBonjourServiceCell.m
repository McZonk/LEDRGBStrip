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
//	self.bonjourService.name
	
	NSDictionary* txtRecord = [NSNetService dictionaryFromTXTRecordData:self.bonjourService.TXTRecordData];
	NSLog(@"%@", txtRecord);
	
	NSLog(@"%@", self.bonjourService.addresses);
	
	self.nameView.text = self.bonjourService.name;
	
	self.infoView.text = [NSString stringWithFormat:@"%@:%d", self.bonjourService.domain, self.bonjourService.port];
	
}

@end
