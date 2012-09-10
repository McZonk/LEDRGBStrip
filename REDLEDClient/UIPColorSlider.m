//
//  UIPColorSlider.m
//  RGBLED
//
//  Created by Maximilian Christ on 2012-09-05.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "UIPColorSlider.h"

#import <QuartzCore/QuartzCore.h>


static void* const UIPColorSliderColorsKVOContext = (void*)&UIPColorSliderColorsKVOContext;

static void* const UIPColorSliderValueKVOContext = (void*)&UIPColorSliderValueKVOContext;


@interface UIPColorSlider ()

@property (nonatomic, retain, readonly) CAGradientLayer* layer;

@property (nonatomic, retain) UIImageView* circleView;

@end


@implementation UIPColorSlider

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

- (id)initWithCoder:(NSCoder*)coder
{
	self = [super initWithCoder:coder];
	if(self != nil)
	{
		self.layer.startPoint = CGPointMake(0.0f, 0.5f);
		self.layer.endPoint = CGPointMake(1.0f, 0.5f);

		self.circleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle"]];
		[self addSubview:self.circleView];

		[self addObserver:self forKeyPath:@"colors" options:0 context:UIPColorSliderColorsKVOContext];
		[self addObserver:self forKeyPath:@"value" options:0 context:UIPColorSliderValueKVOContext];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self != nil)
	{
		self.layer.startPoint = CGPointMake(0.0f, 0.5f);
		self.layer.endPoint = CGPointMake(1.0f, 0.5f);
	
		self.circleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle"]];
		[self addSubview:self.circleView];

		[self addObserver:self forKeyPath:@"colors" options:0 context:UIPColorSliderColorsKVOContext];
		[self addObserver:self forKeyPath:@"value" options:0 context:UIPColorSliderValueKVOContext];
	}
	return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"colors"];
	[self removeObserver:self forKeyPath:@"value"];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
	if(context == UIPColorSliderColorsKVOContext)
	{
		NSMutableArray* colors = [NSMutableArray arrayWithCapacity:self.colors.count];
		for(UIColor* color in self.colors)
		{
			[colors addObject:(id)color.CGColor];
		}
		self.layer.colors = colors;
	}
	else if(context == UIPColorSliderValueKVOContext)
	{
		CGSize size = self.frame.size;
		CGSize imageSize = self.circleView.frame.size;
		
		self.circleView.frame = CGRectMake((size.width * self.value) - imageSize.width * 0.5f, (size.height - imageSize.height) * 0.5f, imageSize.width, imageSize.height);
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (CGFloat)valueForTouch:(UITouch*)touch
{
	CGFloat x = [touch locationInView:self].x;
	
	x /= self.bounds.size.width;
	if(x < 0.0f)
	{
		x = 0.0f;
	}
	else if(x > 1.0f)
	{
		x = 1.0f;
	}
	
	return x;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = touches.anyObject;
	self.value = [self valueForTouch:touch];

	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = touches.anyObject;
	self.value = [self valueForTouch:touch];
	
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@dynamic layer;

@end
