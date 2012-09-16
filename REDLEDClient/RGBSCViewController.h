//
//  RGBSCViewController.h
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIPColorSlider.h"
#import "UIPRangeSelector.h"


@interface RGBSCViewController : UIViewController

- (void)bindToNetService:(NSNetService*)netService;

@property (nonatomic, weak, readonly) IBOutlet UIPColorSlider* hSlider;
@property (nonatomic, weak, readonly) IBOutlet UIPColorSlider* sSlider;
@property (nonatomic, weak, readonly) IBOutlet UIPColorSlider* bSlider;
@property (nonatomic, weak, readonly) IBOutlet UIPRangeSelector* rangeSlider;

@property (nonatomic, weak, readonly) IBOutlet UILabel* firstTextView;
@property (nonatomic, weak, readonly) IBOutlet UILabel* lastTextView;


- (IBAction)sliderChanged:(id)sender;
- (IBAction)ledRangeChanged:(id)sender;

@end
