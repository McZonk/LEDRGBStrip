//
//  ColorCollectionViewCell.h
//  REDLEDClient
//
//  Created by Michael Ochs on 9/23/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ColorCollectionViewCellDelegate <UICollectionViewDelegate>
@optional

- (void)collectionView:(UICollectionView*)collectionView deleteButtonTappedAtIndexPath:(NSIndexPath*)indexPath;

@end


@interface ColorCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readwrite) UIColor* color;

@property (nonatomic, assign, readwrite) BOOL editing;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@end
