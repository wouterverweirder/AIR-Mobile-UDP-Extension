//
//  UDPPacket.h
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 09/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



@interface UDPPacket : NSObject

@property (nonatomic, strong) NSString *srcAddress;
@property (nonatomic) UInt16 srcPort;

@property (nonatomic, strong) NSString *dstAddress;
@property (nonatomic) UInt16 dstPort;
@property (nonatomic, strong) NSData *data;

@end
