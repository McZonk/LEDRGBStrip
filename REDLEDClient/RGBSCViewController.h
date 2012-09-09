//
//  RGBSCViewController.h
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGBSCViewController : UIViewController

- (void)bindToAddress:(NSData*)address;

@property (nonatomic, strong) IBOutlet UISlider* rSlider;
@property (nonatomic, strong) IBOutlet UISlider* gSlider;
@property (nonatomic, strong) IBOutlet UISlider* bSlider;

- (IBAction)sliderChanged:(id)sender;

@end
