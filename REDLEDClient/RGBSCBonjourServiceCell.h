//
//  RGBSCBonjourServiceCell.h
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGBSCBonjourServiceCell : UITableViewCell

@property (nonatomic, strong) NSNetService* bonjourService;

@property (nonatomic, weak) IBOutlet UILabel* nameView;
@property (nonatomic, weak) IBOutlet UILabel* infoView;

@end
