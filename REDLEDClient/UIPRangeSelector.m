//
//  UIPRangeSelector.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/16/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "UIPRangeSelector.h"


static void* const UIPRangeSelectorValueChangedContext = (void*)&UIPRangeSelectorValueChangedContext;
static void* const UIPRangeSelectorMaxRangeChangedContext = (void*)&UIPRangeSelectorMaxRangeChangedContext;


@interface UIPRangeSelector ()

@property (nonatomic, assign, readwrite) CGPoint beginningTouchPoint;
@property (nonatomic, assign, readwrite) NSUInteger beginningLocation;
@property (nonatomic, assign, readwrite) NSUInteger lastNumberOfTouches;

@property (nonatomic, weak, readwrite) UIImageView* highlightImageView;

@property (nonatomic, assign, readwrite) NSRange value;

@end


@implementation UIPRangeSelector

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self addObserver:self forKeyPath:@"value" options:0 context:UIPRangeSelectorValueChangedContext];
		[self addObserver:self forKeyPath:@"maximumRange" options:0 context:UIPRangeSelectorMaxRangeChangedContext];
		
		UIImageView* highlightImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0f, 3.0f, 1.0f, 3.0f)]];
		[self addSubview:highlightImageView];
		self.highlightImageView = highlightImageView;
		
		[self registerTouchRecognizers];
		
		self.maximumRange = NSMakeRange(0, 128);
		self.value = self.maximumRange;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self addObserver:self forKeyPath:@"value" options:0 context:UIPRangeSelectorValueChangedContext];
		[self addObserver:self forKeyPath:@"maximumRange" options:0 context:UIPRangeSelectorMaxRangeChangedContext];
		
		UIImageView* highlightImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0f, 3.0f, 1.0f, 3.0f)]];
		[self addSubview:highlightImageView];
		self.highlightImageView = highlightImageView;
		
		[self registerTouchRecognizers];
		
		self.maximumRange = NSMakeRange(0, 128);
		self.value = self.maximumRange;
	}
	return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"value" context:UIPRangeSelectorValueChangedContext];
	[self removeObserver:self forKeyPath:@"maximumRange" context:UIPRangeSelectorMaxRangeChangedContext];
}



#pragma mark - Setup

- (void)registerTouchRecognizers {
	UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
	pan.minimumNumberOfTouches = 1;
	pan.maximumNumberOfTouches = 2;
	[self addGestureRecognizer:pan];
}



#pragma mark - Touch handling

- (void)panRecognized:(UIGestureRecognizer*)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan || self.lastNumberOfTouches != recognizer.numberOfTouches) {
		self.beginningTouchPoint = (recognizer.numberOfTouches > 0 ? [recognizer locationOfTouch:0 inView:self] : CGPointZero);
		self.beginningLocation = self.value.location;
	}
	
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		NSRange nextValue = NSMakeRange(self.beginningLocation, self.value.length);
		
		if (recognizer.numberOfTouches == 1) {
			//first touch calculates location
			CGPoint point = [recognizer locationOfTouch:0 inView:self];
			point.x = fmaxf(fminf(point.x, self.bounds.size.width), 0.0f);
			CGFloat offset = point.x - self.beginningTouchPoint.x;
			CGFloat percentage = offset / self.bounds.size.width;
			nextValue.location += (percentage * self.maximumRange.length);
			
		} else if (recognizer.numberOfTouches > 1) {
			//with two touches given, the touch points are the position of the edges of the range
			CGPoint firstPoint = [recognizer locationOfTouch:0 inView:self];
			firstPoint.x = fmaxf(fminf(firstPoint.x, self.bounds.size.width), 0.0f);
			CGFloat firstPercentage = firstPoint.x / self.bounds.size.width;
			
			CGPoint secondPoint = [recognizer locationOfTouch:1 inView:self];
			secondPoint.x = fmaxf(fminf(secondPoint.x, self.bounds.size.width), 0.0f);
			CGFloat secondPercentage = secondPoint.x / self.bounds.size.width;
			
			if (firstPercentage < secondPercentage) { //first is left
				nextValue.location = self.maximumRange.location + firstPercentage * self.maximumRange.length;
				nextValue.length = secondPercentage * self.maximumRange.length - nextValue.location;
			} else { //second is left
				nextValue.location = self.maximumRange.location + secondPercentage * self.maximumRange.length;
				nextValue.length = firstPercentage * self.maximumRange.length - nextValue.location;
			}
		}
		
		//move value to valid range!
		if (NSMaxRange(nextValue) > NSMaxRange(self.maximumRange)) {
			nextValue.location -= NSMaxRange(nextValue) - NSMaxRange(self.maximumRange);
		}
		nextValue = NSIntersectionRange(nextValue, self.maximumRange);
		
		self.value = nextValue;
	}
	
	self.lastNumberOfTouches = recognizer.numberOfTouches;
}



#pragma mark - Value handling

- (void)setHighlightImage:(UIImage *)highlightImage {
	self.highlightImageView.image = highlightImage;
}

- (UIImage*)highlightImage {
	return self.highlightImageView.image;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == UIPRangeSelectorValueChangedContext) {
		CGFloat stepSize = self.bounds.size.width / self.maximumRange.length;
		self.highlightImageView.frame = CGRectMake((self.value.location - self.maximumRange.location) * stepSize, 0.0f, self.value.length * stepSize, self.bounds.size.height);
		
		[self sendActionsForControlEvents:UIControlEventValueChanged];
		
	} else if (context == UIPRangeSelectorMaxRangeChangedContext) {
		self.value = NSIntersectionRange(self.value, self.maximumRange);
	}
}

@end
