//
//  RGBSCOverviewViewController.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/22/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCOverviewViewController.h"

#import "ColorMessage.h"
#import "MCUDPSocket.h"

#import <QuartzCore/QuartzCore.h>
#import "AddItemCollectionViewCell.h"
#import "ColorCollectionViewCell.h"

#import "RGBSCColorChooserViewController.h"


typedef struct ColorAbstraction_ {
	float hue;
	float satturation;
} ColorAbstraction;


@interface RGBSCOverviewViewController () <NSNetServiceDelegate, RGBSCColorChooserViewControllerDelegate>

@property (nonatomic, strong, readwrite) NSArray* colors;

@end


static NSString* const ColorCollectionCellIdentifier = @"ColorCollectionCellIdentifier";
static NSString* const ColorAddCollectionCellIdentifier = @"ColorAddCollectionCellIdentifier";


@implementation RGBSCOverviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		
		[self loadColors];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		
		[self loadColors];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.colorCollectionView registerClass:[ColorCollectionViewCell class] forCellWithReuseIdentifier:ColorCollectionCellIdentifier];
	[self.colorCollectionView registerClass:[AddItemCollectionViewCell class] forCellWithReuseIdentifier:ColorAddCollectionCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateColorOnDevice];
}



#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (editing) {
		[self.colorCollectionView insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:self.colors.count inSection:0] ]];
	} else {
		[self.colorCollectionView deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:self.colors.count inSection:0] ]];
	}
}



#pragma mark - Color Handling

- (NSURL*)_colorFileURL {
	NSURL* documentsURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
	return [[documentsURL URLByAppendingPathComponent:@"colors"] URLByAppendingPathExtension:@"hs"];
}

- (void)loadColors {
	if ([[self _colorFileURL] checkResourceIsReachableAndReturnError:NULL]) {
		NSData* data = [NSData dataWithContentsOfURL:[self _colorFileURL]];
		ColorAbstraction* rawColors = (ColorAbstraction*)data.bytes;
		NSMutableArray* colors = [NSMutableArray arrayWithCapacity:data.length / sizeof(ColorAbstraction)];
		for (int i = 0; i < data.length / sizeof(ColorAbstraction); i++) {
			[colors addObject:[NSValue valueWithBytes:rawColors+i objCType:@encode(ColorAbstraction)]];
		}
		self.colors = [NSArray arrayWithArray:colors];
	} else {
		ColorAbstraction white = { 0.0f, 0.0f };
		ColorAbstraction warmWhite = { 0.11f, 0.6f };
		ColorAbstraction red = { 0.0f, 1.0f };
		ColorAbstraction orange = { 0.083f, 1.0f };
		ColorAbstraction green = { 0.3333f, 1.0f };
		ColorAbstraction chartreuse = { 0.25f, 1.0f };
		ColorAbstraction blue = { 0.6666f, 1.0f };
		ColorAbstraction lightBlue = { 0.6666f, 0.25f };
		self.colors = @[ [NSValue valueWithBytes:&white objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&red objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&green objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&blue objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&warmWhite objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&orange objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&chartreuse objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&lightBlue objCType:@encode(ColorAbstraction)] ];
	}
}

- (void)saveColors {
	NSMutableData* data = [NSMutableData data];
	for (int i = 0; i < self.colors.count; i++) {
		ColorAbstraction color;
		[self.colors[i] getValue:&color];
		[data appendBytes:&color length:sizeof(ColorAbstraction)];
	}
	[data writeToURL:[self _colorFileURL] atomically:YES];
}



#pragma mark - Brightness

- (IBAction)changeBrightness:(id)sender {
	[self updateColorOnDevice];
}



#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if (self.isEditing) {
		return self.colors.count + 1;
	} else {
		return self.colors.count;
	}
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.item < self.colors.count) {
		ColorCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ColorCollectionCellIdentifier forIndexPath:indexPath];
		
		ColorAbstraction cellColor;
		[self.colors[indexPath.item] getValue:&cellColor];
		cell.color = [UIColor colorWithHue:cellColor.hue saturation:cellColor.satturation brightness:1.0f alpha:1.0f];
		
		return cell;
		
	} else {
		// add-new-color item
		UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ColorAddCollectionCellIdentifier forIndexPath:indexPath];
		
		return cell;
	}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (self.editing) {
		[self performSegueWithIdentifier:@"ColorPicker" sender:indexPath];
	} else {
		if (indexPath.item < self.colors.count) {
			[self updateColorOnDevice];
		} else {
			[NSException raise:NSInternalInconsistencyException format:@"This shouldn't happen!"];
		}
	}
}



#pragma mark - Colorpicker management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ColorPicker"]) {
		NSIndexPath* indexPath = sender;
		
		RGBSCColorChooserViewController* colorChooser = (RGBSCColorChooserViewController*)[(UINavigationController*)segue.destinationViewController topViewController];
		if (![colorChooser isKindOfClass:[RGBSCColorChooserViewController class]]) {
			[NSException raise:NSInternalInconsistencyException format:@"Content view controller in 'ColorPicker' segue musst be a RGBSCColorChooserViewController!"];
		}
		[colorChooser bindToNetService:self.service];
		if (indexPath.item < self.colors.count) {
			ColorAbstraction abstractColor;
			[self.colors[indexPath.item] getValue:&abstractColor];
			
			UIColor* color = [UIColor colorWithHue:abstractColor.hue saturation:abstractColor.satturation brightness:1.0f alpha:1.0f];
			[colorChooser setColor:color];
		}
		[colorChooser setColorPickedHandler:^(UIColor* color) {
			ColorAbstraction colorAbstraction;
			[color getHue:&colorAbstraction.hue saturation:&colorAbstraction.satturation brightness:NULL alpha:NULL];
			NSValue* colorValue = [NSValue valueWithBytes:&colorAbstraction objCType:@encode(ColorAbstraction)];
			
			if (indexPath.item >= self.colors.count) {
				self.colors = [self.colors arrayByAddingObject:colorValue];
				[self.colorCollectionView insertItemsAtIndexPaths:@[indexPath]];
			} else {
				NSMutableArray* array = [self.colors mutableCopy];
				[array replaceObjectAtIndex:indexPath.item withObject:colorValue];
				self.colors = [NSArray arrayWithArray:array];
				[self.colorCollectionView reloadItemsAtIndexPaths:@[indexPath]];
			}
			[self.colorCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
			[self saveColors];
		}];
	}
}



#pragma mark - Networking

- (void)updateColorOnDevice {
	NSIndexPath* indexPath = [self.colorCollectionView.indexPathsForSelectedItems lastObject];
	
	UIColor* color = nil;
	
	if (indexPath.item >= self.colors.count) {
		color = [UIColor colorWithHue:0.0f saturation:0.0f brightness:self.brightnessSlider.value alpha:1.0f];
	} else {
		ColorAbstraction abstractColor;
		[self.colors[[(NSIndexPath*)[self.colorCollectionView.indexPathsForSelectedItems lastObject] item]] getValue:&abstractColor];
		
		color = [UIColor colorWithHue:abstractColor.hue saturation:abstractColor.satturation brightness:self.brightnessSlider.value alpha:1.0f];
	}
	[self sendColorToDevice:color range:NSMakeRange(0, self.ledCount)];
}


@end
