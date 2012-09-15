//
//  RGBSCViewController.h
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIPColorSlider.h"

@interface RGBSCViewController : UIViewController

- (void)bindToNetService:(NSNetService*)netService;

@property (nonatomic, strong) IBOutlet UIPColorSlider* hSlider;
@property (nonatomic, strong) IBOutlet UIPColorSlider* sSlider;
@property (nonatomic, strong) IBOutlet UIPColorSlider* bSlider;

@property (nonatomic, strong) IBOutlet UIStepper* firstStepper;
@property (nonatomic, strong) IBOutlet UIStepper* lastStepper;

@property (nonatomic, strong) IBOutlet UILabel* firstTextView;
@property (nonatomic, strong) IBOutlet UILabel* lastTextView;

- (IBAction)sliderChanged:(id)sender;

- (IBAction)firstLEDChanged:(id)sender;
- (IBAction)lastLEDChanged:(id)sender;

@end
