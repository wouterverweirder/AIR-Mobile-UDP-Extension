//
//  UDPPacket.h
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 09/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



@interface UDPPacket : NSObject
{
@public
    NSString * srcAddress;
    UInt16 srcPort;
    NSString * dstAddress;
    UInt16 dstPort;
    NSData * data;
}
@end
