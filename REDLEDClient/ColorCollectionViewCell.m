//
//  ColorCollectionViewCell.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/23/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "ColorCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>
#import "UIColor+Names.h"


@interface ColorCollectionViewCell ()

@property (nonatomic, weak, readwrite) UILabel* colorNameLabel;

@end


static void* const ColorKVOContext = (void*)&ColorKVOContext;


@implementation ColorCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.layer.borderColor = [[UIColor blackColor] CGColor];
		self.layer.borderWidth = 1.0f;
		
		[self createColorTextLabel];
		[self addObserver:self forKeyPath:@"color" options:0 context:ColorKVOContext];
		
		self.color = [UIColor whiteColor];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.layer.borderColor = [[UIColor blackColor] CGColor];
		self.layer.borderWidth = 1.0f;
		
		[self createColorTextLabel];
		[self addObserver:self forKeyPath:@"color" options:0 context:ColorKVOContext];
		
		self.color = [UIColor whiteColor];
	}
	return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"color" context:ColorKVOContext];
}

- (void)createColorTextLabel {
	UIEdgeInsets textInset = UIEdgeInsetsMake(self.bounds.size.height / 10.0f, self.bounds.size.width / 10.0f, self.bounds.size.height / 10.0f, self.bounds.size.width / 10.0f);
	
	UILabel* label = [[UILabel alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, textInset)];
	label.contentMode = UIViewContentModeBottom;
	label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	label.textColor = [UIColor blackColor];
	label.shadowColor = [UIColor whiteColor];
	label.shadowOffset = CGSizeMake(0.0f, 1.0f);
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	[self addSubview:label];
	self.colorNameLabel = label;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == ColorKVOContext) {
		self.backgroundColor = self.color;
		self.colorNameLabel.backgroundColor = self.color;
		self.colorNameLabel.text = [self.color simpleColorName];
	}
}

@end
