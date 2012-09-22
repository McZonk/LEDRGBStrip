//
//  RGBSCOverviewViewController.h
//  REDLEDClient
//
//  Created by Michael Ochs on 9/22/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGBSCOverviewViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak, readonly) IBOutlet UISlider* brightnessSlider;
@property (nonatomic, weak, readonly) IBOutlet UICollectionView* colorCollectionView;

- (IBAction)changeBrightness:(id)sender;

- (void)bindToNetService:(NSNetService*)service;

@end
