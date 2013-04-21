//
//  UDPPacket.m
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 09/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UDPPacket.h"

@implementation UDPPacket

@synthesize data = _data, dstAddress = _dstAddress, dstPort = _dstPort, srcAddress = _srcAddress, srcPort = _srcPort;

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}


@end
