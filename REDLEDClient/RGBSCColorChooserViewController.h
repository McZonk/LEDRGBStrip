//
//  RGBSCColorChooserViewController.h
//  REDLEDClient
//
//  Created by Michael Ochs on 9/23/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCDeviceConnectionViewController.h"

#import "UIPHSColorSelectorView.h"


@class RGBSCColorChooserViewController;

@protocol RGBSCColorChooserViewControllerDelegate <NSObject>
@optional

- (void)colorChooser:(RGBSCColorChooserViewController*)colorChooser didFinishPickingColor:(UIColor*)color;
- (void)colorChooserDidCancelPickingColor:(RGBSCColorChooserViewController*)colorChooser;

@end


@interface RGBSCColorChooserViewController : RGBSCDeviceConnectionViewController

@property (nonatomic, weak, readwrite) id<RGBSCColorChooserViewControllerDelegate> delegate;
@property (nonatomic, copy, readwrite) void(^colorPickedHandler)(UIColor* color);

@property (nonatomic, weak, readonly) IBOutlet UIPHSColorSelectorView* colorSelector;

@property (nonatomic, strong, readwrite) UIColor* color;

@end
