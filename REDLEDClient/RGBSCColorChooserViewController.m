//
//  RGBSCColorChooserViewController.m
//  REDLEDClient
//
//  Created by Michael Ochs on 9/23/12.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCColorChooserViewController.h"


@interface RGBSCColorChooserViewController ()

@end


static void* const ColorViewChangedColorContext = (void*)&ColorViewChangedColorContext;
static void* const ColorChangedContext = (void*)&ColorChangedContext;


@implementation RGBSCColorChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self configureNavigationItems];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configureNavigationItems];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.colorSelector addObserver:self forKeyPath:@"color" options:0 context:ColorViewChangedColorContext];
	
	self.colorSelector.color = self.color;
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.colorSelector removeObserver:self forKeyPath:@"color" context:ColorViewChangedColorContext];
	
	[super viewDidDisappear:animated];
}

- (void)configureNavigationItems {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
}



#pragma mark - nav bar

- (void)cancel:(id)selector {
	if ([self.delegate respondsToSelector:@selector(colorChooserDidCancelPickingColor:)]) {
		[self.delegate colorChooserDidCancelPickingColor:self];
	} else {
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (void)save:(id)selector {
	if (self.colorPickedHandler != NULL) {
		self.colorPickedHandler(self.colorSelector.color);
		self.colorPickedHandler = NULL;
	}
	
	if ([self.delegate respondsToSelector:@selector(colorChooser:didFinishPickingColor:)]) {
		[self.delegate colorChooser:self didFinishPickingColor:self.colorSelector.color];
	} else {
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}



#pragma mark - Color

- (void)updateColorOnDevice {
	[self sendColorToDevice:self.color range:NSMakeRange(0, self.ledCount)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	static BOOL syncingColor = NO;
	if (syncingColor) {
		return;
	}
	syncingColor = YES;
	if (context == ColorViewChangedColorContext) {
		self.color = self.colorSelector.color;
		[self updateColorOnDevice];
		
	} else if (context == ColorChangedContext) {
		self.colorSelector.color = self.color;
	}
	syncingColor = NO;
}

@end
