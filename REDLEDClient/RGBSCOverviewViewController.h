//
//  RGBSCOverviewViewController.h
//  REDLEDClient
//
//  Created by Michael Ochs on 9/22/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCDeviceConnectionViewController.h"

@interface RGBSCOverviewViewController : RGBSCDeviceConnectionViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak, readonly) IBOutlet UISlider* brightnessSlider;
@property (nonatomic, weak, readonly) IBOutlet UICollectionView* colorCollectionView;

- (IBAction)changeBrightness:(id)sender;

@end
