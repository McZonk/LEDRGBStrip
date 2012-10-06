//
//  RGBSCDeviceConnectionViewController.h
//  REDLEDClient
//
//  Created by Michael Ochs on 9/23/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGBSCDeviceConnectionViewController : UIViewController

@property (nonatomic, strong, readonly) NSNetService* service;
@property (nonatomic, assign, readonly) NSUInteger ledCount;

- (void)sendColorToDevice:(UIColor*)color range:(NSRange)range;
- (void)bindToNetService:(NSNetService*)service;

// Subclassing
- (void)applicationDidEnterBackground:(NSNotification*)aNotification;
- (void)applicationWillEnterForeground:(NSNotification*)aNotification;

@end
