//
//  UIColor+Names.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/22/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "UIColor+Names.h"

@implementation UIColor (Names)

- (NSString*)simpleColorName {
	static NSDictionary* colorDictionary = nil;
	static NSDictionary* saturationDictionary = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		colorDictionary = @{
							@(0.0f) : @"red",
							@(0.083f) : @"orange",
							@(0.166f) : @"yellow",
							@(0.25f) : @"chartreuse",
							@(0.333f) : @"green",
							@(0.416f) : @"mint",
							@(0.5f) : @"turquoise",
							@(0.666f) : @"blue",
							@(0.75f) : @"purple",
							@(0.833f) : @"pink",
							@(0.916f) : @"magenta",
							@(1.0f) : @"red"
						};
		saturationDictionary = @{ @(0.0f) : @"white", @(0.5f) : @"light %@", @(0.75) : @"medium %@", @(1.0f) : @"%@" };
	});
	
	NSString* colorname = nil;
	
	CGFloat hue;
	CGFloat saturation;
	[self getHue:&hue saturation:&saturation brightness:NULL alpha:NULL];
	
	{ //colorname
		NSMutableArray* colors = [NSMutableArray arrayWithArray:[colorDictionary allKeys]];
		[colors addObject:@(hue)];
		[colors sortUsingSelector:@selector(compare:)];
		
		NSUInteger colorIndex = [colors indexOfObject:@(hue)];
		float dist1 = (colorIndex > 0 ? hue - [colors[colorIndex-1] floatValue] : HUGE_VALF);
		float dist2 = (colorIndex < colors.count - 1 ? [colors[colorIndex+1] floatValue] - hue : HUGE_VALF);
		if (dist1 < dist2) {
			colorname = colorDictionary[colors[colorIndex-1]];
		} else {
			colorname = colorDictionary[colors[colorIndex+1]];
		}
	}
	
	{ //saturation
		NSMutableArray* saturations = [NSMutableArray arrayWithArray:[saturationDictionary allKeys]];
		[saturations addObject:@(saturation)];
		[saturations sortUsingSelector:@selector(compare:)];
		
		NSUInteger saturationIndex = [saturations indexOfObject:@(saturation)];
		float dist1 = (saturationIndex > 0 ? saturation - [saturations[saturationIndex-1] floatValue] : HUGE_VALF);
		float dist2 = (saturationIndex < saturations.count - 1 ? [saturations[saturationIndex+1] floatValue] - saturation : HUGE_VALF);
		if (dist1 < dist2) {
			colorname = [NSString stringWithFormat:saturationDictionary[saturations[saturationIndex-1]], colorname];
		} else {
			colorname = [NSString stringWithFormat:saturationDictionary[saturations[saturationIndex+1]], colorname];
		}
	}
	
	return colorname;
}

@end
