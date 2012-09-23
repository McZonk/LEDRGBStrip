//
//  UIPHSColorSelectorView.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/23/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "UIPHSColorSelectorView.h"

#import <QuartzCore/QuartzCore.h>


@interface UIPHSColorSelectorView()

@property (nonatomic, weak, readwrite) CAGradientLayer* hueGradientLayer;
@property (nonatomic, weak, readwrite) CAGradientLayer* saturationGradientLayer;

@end


@implementation UIPHSColorSelectorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self configureLayer];
		[self configurePicking];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configureLayer];
		[self configurePicking];
	}
	return self;
}

- (void)configureLayer {
	CAGradientLayer* hue = [[CAGradientLayer alloc] init];
	hue.frame = self.layer.bounds;
	hue.startPoint = CGPointMake(0.0f, 0.5f);
	hue.endPoint = CGPointMake(1.0f, 0.5f);
	[self.layer addSublayer:hue];
	self.hueGradientLayer = hue;
	
	CAGradientLayer* sat = [[CAGradientLayer alloc] init];
	sat.frame = self.layer.bounds;
	[self.layer addSublayer:sat];
	self.saturationGradientLayer = sat;
	
	//colors
	self.hueGradientLayer.colors = @[
										(id)[[UIColor colorWithHue:0.0f saturation:1.0f brightness:1.0f alpha:1.0f] CGColor],
										(id)[[UIColor colorWithHue:1.0f/6.0f saturation:1.0f brightness:1.0f alpha:1.0f] CGColor],
										(id)[[UIColor colorWithHue:2.0f/6.0f saturation:1.0f brightness:1.0f alpha:1.0f] CGColor],
										(id)[[UIColor colorWithHue:3.0f/6.0f saturation:1.0f brightness:1.0f alpha:1.0f] CGColor],
										(id)[[UIColor colorWithHue:4.0f/6.0f saturation:1.0f brightness:1.0f alpha:1.0f] CGColor],
										(id)[[UIColor colorWithHue:5.0f/6.0f saturation:1.0f brightness:1.0f alpha:1.0f] CGColor],
										(id)[[UIColor colorWithHue:1.0f saturation:1.0f brightness:1.0f alpha:1.0f] CGColor]
									];
	
	self.saturationGradientLayer.colors = @[ (id)[[UIColor whiteColor] CGColor], (id)[[UIColor clearColor] CGColor] ];
}

- (void)configurePicking {
	UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updatePanning:)];
	[self addGestureRecognizer:pan];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.hueGradientLayer.frame = self.layer.bounds;
	self.saturationGradientLayer.frame = self.layer.bounds;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	UIEdgeInsets inset = UIEdgeInsetsMake(-20.0f, -20.0f, -20.0f, -20.0f);
	return CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, inset), point);
}

- (void)updatePanning:(UIPanGestureRecognizer*)gestureRecognizer {
	CGPoint point = [gestureRecognizer locationInView:self];
	
	CGPoint color = CGPointMake(point.x / self.bounds.size.width, point.y / self.bounds.size.height);
	
	//clamp
	color.x = fmaxf(color.x, 0.0f);
	color.y = fmaxf(color.y, 0.0f);
	color.x = fminf(color.x, 1.0f);
	color.y = fminf(color.y, 1.0f);
	
	self.color = [UIColor colorWithHue:color.x saturation:color.y brightness:1.0f alpha:1.0f];
}

@end
