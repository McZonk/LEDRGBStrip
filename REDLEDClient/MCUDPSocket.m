//
//  MCUDPSocket.m
//  RGBLED
//
//  Created by Maximilian Christ on 2012-09-05.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "MCUDPSocket.h"

#import <netinet/in.h>

@interface MCUDPSocket ()
{
	CFSocketRef socket;
	
	CFRunLoopSourceRef runloopSource;
}

@property (nonatomic, strong) NSData* address;

- (void)gotData:(NSData*)data;

@end


static void SocketCallBack(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
	MCUDPSocket* socket = (__bridge MCUDPSocket*)info;
	
	if(type == kCFSocketReadCallBack)
	{

	}
	else if(type == kCFSocketDataCallBack)
	{
		[socket gotData:(__bridge NSData*)data];
	}
	else
	{
//		NSLog(@"%d", type);
	}
}


@implementation MCUDPSocket

- (id)initWithAddress:(NSData*)address
{
	self = [super init];
	if(self != nil)
	{
		const CFSocketContext context = { 0, (__bridge void*)self, NULL, NULL, NULL };
		
		socket = CFSocketCreate(NULL, AF_INET, SOCK_DGRAM, IPPROTO_UDP, kCFSocketDataCallBack, SocketCallBack, &context);

		runloopSource = CFSocketCreateRunLoopSource(NULL, socket, 0);
		CFRunLoopAddSource(CFRunLoopGetCurrent(), runloopSource, kCFRunLoopDefaultMode);

		self.address = address;
	}
	return self;
}

- (void)dealloc
{
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runloopSource, kCFRunLoopDefaultMode);
	CFRelease(runloopSource), runloopSource = NULL;
	
	CFRelease(socket), socket = NULL;
}

- (BOOL)sendData:(NSData*)data
{
	CFSocketError error = CFSocketSendData(socket, (__bridge CFDataRef)self.address, (__bridge CFDataRef)data, 5.0);
	
	return error == kCFSocketSuccess;
}

- (void)gotData:(NSData*)data
{
	NSString* string = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSASCIIStringEncoding];
	
	NSLog(@"getData: %@", string);
}

@end
