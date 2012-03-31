//
//  UDPSocketAdapter.h
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 08/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "FlashRuntimeExtensions.h"
#include "AsyncUdpSocket.h"
#include "UDPPacket.h"

@interface UDPSocketAdapter : NSObject
{
    AsyncUdpSocket *listenSocket;
    AsyncUdpSocket *sendSocket;
    
    FREContext _ctx;
    int _port;
    
    NSMutableArray *theReceiveQueue;
}
- (id)initWithContext:(FREContext)ctx;
- (BOOL)send:(NSData *)data toHost:(NSString *)host port:(int)port;
- (BOOL)bind:(int)port;
- (BOOL)receive;
- (UDPPacket *)readPacket;
- (BOOL)close;
@end
