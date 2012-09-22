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


typedef struct ColorAbstraction_ {
	float hue;
	float satturation;
} ColorAbstraction;


@interface RGBSCOverviewViewController () <NSNetServiceDelegate>

@property (nonatomic, strong, readwrite) NSNetService* service;
@property (nonatomic, strong, readwrite) NSArray* colors;

@property (nonatomic, assign, readwrite) NSUInteger ledCount;

@property (nonatomic, strong, readwrite) MCUDPSocket* socket;

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
	
	[self.colorCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ColorCollectionCellIdentifier];
	[self.colorCollectionView registerClass:[AddItemCollectionViewCell class] forCellWithReuseIdentifier:ColorAddCollectionCellIdentifier];
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
		ColorAbstraction red = { 0.0f, 1.0f };
		ColorAbstraction green = { 0.3333f, 1.0f };
		ColorAbstraction blue = { 0.6666f, 1.0f };
		self.colors = @[ [NSValue valueWithBytes:&white objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&red objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&green objCType:@encode(ColorAbstraction)], [NSValue valueWithBytes:&blue objCType:@encode(ColorAbstraction)] ];
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
		UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ColorCollectionCellIdentifier forIndexPath:indexPath];
		
		cell.layer.borderColor = [[UIColor blackColor] CGColor];
		cell.layer.borderWidth = 1.0f / collectionView.window.screen.scale;
		
		ColorAbstraction cellColor;
		[self.colors[indexPath.item] getValue:&cellColor];
		cell.backgroundColor = [UIColor colorWithHue:cellColor.hue saturation:cellColor.satturation brightness:1.0f alpha:1.0f];
		
		return cell;
		
	} else {
		// add-new-color item
		UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ColorAddCollectionCellIdentifier forIndexPath:indexPath];
		
		return cell;
	}
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.item < self.colors.count) {
		[self updateColorOnDevice];
	} else {
		NSLog(@"ADD COLOR!");
	}
}



#pragma mark - Networking

- (void)updateColorOnDevice {
	ColorAbstraction abstractColor;
	[self.colors[[(NSIndexPath*)[self.colorCollectionView.indexPathsForSelectedItems lastObject] item]] getValue:&abstractColor];
	
	UIColor* color = [UIColor colorWithHue:abstractColor.hue saturation:abstractColor.satturation brightness:self.brightnessSlider.value alpha:1.0f];
	[self sendColorToDevice:color range:NSMakeRange(0, self.ledCount)];
}

- (void)sendColorToDevice:(UIColor*)color range:(NSRange)range {
	float hue;
	float saturation;
	float brightness;
	[color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
	
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorMessage::size()];
	
	RGBStrip::ColorMessage& message = *(RGBStrip::ColorMessage*)data.mutableBytes;
	message.fillHeader();
	message.offset = range.location;
	message.count = range.length;
	message.color = HSBColor(hue, saturation, brightness);
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
}

- (void)bindToNetService:(NSNetService*)service {
	self.service.delegate = nil;
	
	self.service = service;
	self.service.delegate = self;
	
	NSData* address = [self.service.addresses objectAtIndex:0];
	self.socket = [[MCUDPSocket alloc] initWithAddress:address];
	
	NSDictionary* txtRecord = [NSNetService dictionaryFromTXTRecordData:self.service.TXTRecordData];
	{
		NSData* ledsData = [txtRecord objectForKey:@"leds"];
		NSString* ledsString = [[NSString alloc] initWithData:ledsData encoding:NSASCIIStringEncoding];
		self.ledCount = ledsString.integerValue;
	}
	
	self.title = [NSString stringWithFormat:@"%@ (%d)", self.service.name, self.ledCount];
}


@end
