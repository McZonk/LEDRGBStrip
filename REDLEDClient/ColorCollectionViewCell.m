//
//  ColorCollectionViewCell.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/23/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "ColorCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>
#import "UIColor+Names.h"


@interface ColorCollectionViewCell ()

@property (nonatomic, weak, readwrite) UIButton* deleteButton;
@property (nonatomic, weak, readwrite) UILabel* colorNameLabel;

@end


static void* const ColorKVOContext = (void*)&ColorKVOContext;


@implementation ColorCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configureShadow];
		[self createColorTextLabel];
		[self createDeleteButton];
		[self addObserver:self forKeyPath:@"color" options:0 context:ColorKVOContext];
		
		self.layer.cornerRadius = 10.0f;
		self.color = [UIColor whiteColor];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self configureShadow];
		[self createColorTextLabel];
		[self createDeleteButton];
		[self addObserver:self forKeyPath:@"color" options:0 context:ColorKVOContext];
		
		self.layer.cornerRadius = 10.0f;
		self.color = [UIColor whiteColor];
	}
	return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"color" context:ColorKVOContext];
}

- (void)configureShadow {
	self.layer.shadowColor = [self.color CGColor];
	self.layer.shadowRadius = (self.selected ? 10.0f : 0.0f);
	self.layer.shadowOpacity = 1.0f;
	self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)createColorTextLabel {
	UIEdgeInsets textInset = UIEdgeInsetsMake(self.bounds.size.height / 10.0f, self.bounds.size.width / 10.0f, self.bounds.size.height / 10.0f, self.bounds.size.width / 10.0f);
	
	UILabel* label = [[UILabel alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, textInset)];
	label.contentMode = UIViewContentModeBottom;
	label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
	label.textColor = [UIColor blackColor];
	label.shadowColor = [UIColor whiteColor];
	label.shadowOffset = CGSizeMake(0.0f, 1.0f);
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	[self addSubview:label];
	self.colorNameLabel = label;
}

- (void)createDeleteButton {
	UIImage* closeImage = [UIImage imageNamed:@"Delete"];
	UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(-closeImage.size.width*.5f, -closeImage.size.height*.5f, closeImage.size.width, closeImage.size.height)];
	[button setImage:closeImage forState:UIControlStateNormal];
	[button addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
	button.hidden = YES;
	[self addSubview:button];
	self.deleteButton = button;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == ColorKVOContext) {
		self.backgroundColor = self.color;
		self.colorNameLabel.backgroundColor = self.color;
		self.colorNameLabel.text = [self.color simpleColorName];
	}
}



#pragma mark - Editing

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (self.editing) {
		UIEdgeInsets inset = UIEdgeInsetsMake(-self.deleteButton.bounds.size.height*.5f, -self.deleteButton.bounds.size.width*.5f, 0.0f, 0.0f);
		return CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, inset), point);
	} else {
		return [super pointInside:point withEvent:event];
	}
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	
	[self configureShadow];
}

- (IBAction)delete:(id)sender {
	if ([self.superview isKindOfClass:[UICollectionView class]]) {
		UICollectionView* collection = (UICollectionView*)self.superview;
		NSIndexPath* indexPath = [collection indexPathForCell:self];
		id<ColorCollectionViewCellDelegate> delegate = (id<ColorCollectionViewCellDelegate>)collection.delegate;
		if ([delegate respondsToSelector:@selector(collectionView:deleteButtonTappedAtIndexPath:)]) {
			[delegate collectionView:collection deleteButtonTappedAtIndexPath:indexPath];
		}
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	self.editing = editing;
	
	UICollectionView* collection = nil;
	NSIndexPath* indexPath = nil;
	if ([self.superview isKindOfClass:[UICollectionView class]]) {
		collection = (UICollectionView*)self.superview;
		indexPath = [collection indexPathForCell:self];
	}
	if (!indexPath || !collection) {
		animated = NO;
	}
	
	if (editing) {
		self.deleteButton.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
		self.deleteButton.hidden = NO;
		[UIView animateWithDuration:(animated ? 0.1 : 0.0) delay:0.01*indexPath.item options:UIViewAnimationCurveEaseOut animations:^{
			self.deleteButton.transform = CGAffineTransformIdentity;
		} completion:NULL];
	} else {
		self.deleteButton.transform = CGAffineTransformIdentity;
		[UIView animateWithDuration:(animated ? 0.1 : 0.0) delay:0.01*indexPath.item options:UIViewAnimationCurveEaseIn animations:^{
			self.deleteButton.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
		} completion:^(BOOL finished){
			self.deleteButton.hidden = YES;
		}];
	}
}


@end
