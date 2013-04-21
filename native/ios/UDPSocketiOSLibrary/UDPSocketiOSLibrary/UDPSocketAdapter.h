//
//  UDPSocketAdapter.h
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 08/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import "UDPPacket.h"
#import "GCDAsyncUdpSocket.h"

@interface UDPSocketAdapter : NSObject
{
    GCDAsyncUdpSocket *udpSocket;
    FREContext _ctx;
    NSMutableArray *theReceiveQueue;
}

- (id)initWithContext:(FREContext)ctx;
- (BOOL)send:(NSData*)data toHost:(NSString*)host port:(int)port;
- (BOOL)bind:(int)port onAddress:(NSString*)address;
- (BOOL)receive;
- (UDPPacket*)readPacket;
- (BOOL)close;

@end
