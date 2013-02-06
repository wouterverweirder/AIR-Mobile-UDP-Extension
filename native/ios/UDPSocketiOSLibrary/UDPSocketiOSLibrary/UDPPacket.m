//
//  UDPPacket.m
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 09/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UDPPacket.h"

@implementation UDPPacket

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)dealloc
{
    [data release];
    [srcAddress release];
    [super dealloc];
}

@end
