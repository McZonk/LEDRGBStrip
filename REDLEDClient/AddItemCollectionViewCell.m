//
//  AddItemCollectionViewCell.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/22/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "AddItemCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>


@implementation AddItemCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self createView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self createView];
	}
	return self;
}

- (void)createView {
	UILabel* label = [[UILabel alloc] initWithFrame:self.bounds];
	label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	label.font = [UIFont boldSystemFontOfSize:36.0f];
	label.textAlignment = UITextAlignmentCenter;
	label.text = @"+";
	label.textColor = [UIColor lightGrayColor];
	label.layer.borderWidth = 4.0f;
	label.layer.borderColor = [[UIColor lightGrayColor] CGColor];
	label.layer.cornerRadius = 10.0f;
	[self addSubview:label];
}

@end
