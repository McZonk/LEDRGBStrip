//
//  UIPRangeSelector.h
//  REDLEDClient
//
//  Created by Michael Ochs on 9/16/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPRangeSelector : UIControl

@property (nonatomic, assign, readwrite) NSRange maximumRange;
@property (nonatomic, assign, readonly) NSRange value;

//visuals
@property (nonatomic, strong, readwrite) UIImage* highlightImage;

@end
