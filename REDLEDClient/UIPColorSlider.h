//
//  UIPColorSlider.h
//  RGBLED
//
//  Created by Maximilian Christ on 2012-09-05.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPColorSlider : UIControl

@property (nonatomic, strong) NSArray* colors;

@property (nonatomic, assign) CGFloat value;

@end
