//
//  MCUDPSocket.h
//  RGBLED
//
//  Created by Maximilian Christ on 2012-09-05.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCUDPSocket : NSObject

- (id)initWithAddress:(NSData*)address;

- (BOOL)sendData:(NSData*)data;

@end
