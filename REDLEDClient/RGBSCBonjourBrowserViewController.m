//
//  RGBSCBonjourBrowserViewController.m
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCBonjourBrowserViewController.h"

#import "RGBSCBonjourServiceCell.h"

#import "RGBSCViewController.h"


@interface RGBSCBonjourBrowserViewController () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, strong) NSMutableArray* unresolvedBonjourServices;
@property (nonatomic, strong) NSMutableArray* resolvedBonjourServices;

@property (nonatomic, strong) NSNetServiceBrowser* bonjourBrowser;

@end


@implementation RGBSCBonjourBrowserViewController

- (id)initWithCoder:(NSCoder*)coder
{
	self = [super initWithCoder:coder];
	if(self != nil)
	{
		self.unresolvedBonjourServices = [NSMutableArray arrayWithCapacity:1];
		self.resolvedBonjourServices = [NSMutableArray arrayWithCapacity:1];
		
		self.bonjourBrowser = [[NSNetServiceBrowser alloc] init];
		self.bonjourBrowser.delegate = self;
		
		//[self.bonjourBrowser scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
		
		[self.bonjourBrowser searchForServicesOfType:@"_rgbled._udp" inDomain:nil];
	}
	return self;
}

- (void)dealloc
{
	//[self.bonjourBrowser removeFromRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
	self.bonjourBrowser.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.resolvedBonjourServices.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	RGBSCBonjourServiceCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RGBSCBonjourServiceCell class])];
	
	cell.bonjourService = [self.resolvedBonjourServices objectAtIndex:indexPath.row];
	
	return cell;
}

#pragma mark - UIViewViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSNetService* bonjourService = [self.resolvedBonjourServices objectAtIndex:indexPath.row];
	
	RGBSCViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RGBSCViewController"];
	NSLog(@"%@", viewController);

	[viewController bindToNetService:bonjourService];
	
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser*)netServiceBrowser
{
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser*)netServiceBrowser
{
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didNotSearch:(NSDictionary*)errorDict
{
	NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, errorDict);
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)netService moreComing:(BOOL)moreComing
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, netService);

	netService.delegate = self;
	[netService resolveWithTimeout:15.0];
	
	[self.unresolvedBonjourServices addObject:netService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)netService moreComing:(BOOL)moreComing
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, netService);

	if(netService.delegate == self)
	{
		netService.delegate = nil;
	}
	
	[self.unresolvedBonjourServices removeObject:netService];
	[self.resolvedBonjourServices removeObject:netService];
	
	if(!moreComing)
	{
		[self.tableView reloadData];
	}
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService*)netService
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, netService);
	
	[self.unresolvedBonjourServices removeObject:netService];
	[self.resolvedBonjourServices addObject:netService];
	
	[self.tableView reloadData];
}

@end
