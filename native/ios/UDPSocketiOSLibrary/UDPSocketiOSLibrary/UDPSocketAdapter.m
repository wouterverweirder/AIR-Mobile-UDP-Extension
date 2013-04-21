//
//  UDPSocketAdapter.m
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 21/04/13.
//
//

#import "UDPSocketAdapter.h"

@interface UDPSocketAdapter ()
{
	long tag;
}
@end

@implementation UDPSocketAdapter

- (id)initWithContext:(FREContext)ctx
{
    self = [super init];
    if(self)
    {
        _ctx = ctx;
        theReceiveQueue = [[NSMutableArray alloc] init];
        
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [udpSocket enableBroadcast:YES error:nil];
    }
    return self;
}

- (BOOL)send:(NSData*)data toHost:(NSString*)host port:(int)port
{
	[udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
    tag++;
    return YES;
}

- (BOOL)bind:(int)port onAddress:(NSString*)address
{
    NSError *error = nil;
    if (![udpSocket bindToPort:port error:&error])
    {
        return NO;
    }
    return YES;
}

- (BOOL)receive
{
    NSError *error = nil;
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error beginReceiving %@", error);
        return NO;
    }
    return YES;
}

- (UDPPacket*)readPacket
{
    if(theReceiveQueue.count > 0)
    {
        UDPPacket *packet = [theReceiveQueue objectAtIndex:0];
        [theReceiveQueue removeObjectAtIndex:0];
        return packet;
    }
    return nil;
}

- (BOOL) close
{
    if(udpSocket)
    {
        [udpSocket close];
        udpSocket = nil;
    }
    return YES;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSLog(@"didReceiveData");
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    
    //create packet
    UDPPacket *packet = [[UDPPacket alloc] init];
    packet.srcPort = port;
    packet.srcAddress = host;
    packet.data = data;
    packet.dstAddress = udpSocket.localHost;
    packet.dstPort = udpSocket.localPort;
    
    //add it to the queue, so Actionscript can pick it up later
    [theReceiveQueue addObject:packet];
    //dispatch the event to the actionscript library
	FREDispatchStatusEventAsync(_ctx, (const uint8_t *) "receive", (const uint8_t *) "");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose");
	FREDispatchStatusEventAsync(_ctx, (const uint8_t *) "close", (const uint8_t *) "");
}

@end
