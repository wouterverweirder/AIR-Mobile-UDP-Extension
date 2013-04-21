//
//  UDPSocketiOSLibrary.m
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 07/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UDPSocketiOSLibrary.h"
#import "UDPSocketAdapter.h"
#import "UDPPacket.h"

NSMutableDictionary *adapterDictionary;

FREObject IsSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    FREObject freIsSupported;
    FRENewObjectFromBool(1, &freIsSupported);
    return freIsSupported;
}

FREObject Send(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    UDPSocketAdapter *adapter = getUDPSocketAdapter(argv[0]);
    uint32_t ipLength;
    const uint8_t* ipValue;
    FREGetObjectAsUTF8( argv[2], &ipLength, &ipValue );
    
    uint32_t portValue;
    FREGetObjectAsUint32(argv[3], &portValue);
    
    //Get Byte Array from flash
    FREObject length;
    FREObject objectByteArray = argv[1];
    FREGetObjectProperty(objectByteArray, (const uint8_t*) "length", &length, NULL);   
    
    int numBytes;
    FREGetObjectAsInt32(length, &numBytes);
    
    char * bytes[numBytes];
    
    FREByteArray byteArray;
    FREAcquireByteArray(objectByteArray, &byteArray);
    memcpy(bytes, byteArray.bytes, numBytes);
    FREReleaseByteArray(objectByteArray);
    
    NSString * host = [NSString stringWithUTF8String: (const char * ) ipValue];
    int port = (int) portValue;
    NSData * data = [NSData dataWithBytes:bytes length:numBytes];
    
    [adapter send:data toHost:host port:port];
    
	return NULL;
}

FREObject Bind(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    UDPSocketAdapter *adapter = getUDPSocketAdapter(argv[0]);
    
    uint32_t portValue;
    FREGetObjectAsUint32(argv[1], &portValue);
    
    uint32_t addressLength;
    const uint8_t* address;
    FREGetObjectAsUTF8(argv[2], &addressLength, &address);
    
    NSString* addressString = [NSString stringWithUTF8String:(const char*) address];
    if([addressString isEqualToString:[NSString stringWithUTF8String:"0.0.0.0"]]) {
        addressString = nil;
    }
    
    BOOL success = [adapter bind:(int) portValue onAddress:addressString];
    
    FREObject result;
    FRENewObjectFromBool(success, &result);
    
    return result;
}

FREObject Receive(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    UDPSocketAdapter *adapter = getUDPSocketAdapter(argv[0]);
    BOOL success = [adapter receive];
    
    FREObject result;
    FRENewObjectFromBool(success, &result);
    
    return result;
}

FREObject ReadPacket(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    UDPSocketAdapter *adapter = getUDPSocketAdapter(argv[0]);
    FREObject result;
    UDPPacket * packet = [adapter readPacket];
    if(packet != nil)
    {
        FREObject type;
        FRENewObjectFromUTF8(4, (const uint8_t *) "data", &type);
        FREObject eventParams [] = {type};
        FRENewObject((const uint8_t *)"flash.events.DatagramSocketDataEvent", 1, eventParams, &result, NULL);
        
        int len = [packet.data length];
        
        FREObject objectByteArray = argv[1];
        
        FREByteArray byteArray;
        FREObject length;
        FRENewObjectFromUint32(len, &length);
        FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
        FREAcquireByteArray(objectByteArray, &byteArray);
        memcpy(byteArray.bytes, [packet.data bytes], len);
        FREReleaseByteArray(objectByteArray);
        
        FREObject srcAddress;
        FRENewObjectFromUTF8([packet.srcAddress length], (const uint8_t*) [packet.srcAddress cStringUsingEncoding:NSUTF8StringEncoding], &srcAddress);
        FRESetObjectProperty(result, (const uint8_t*) "srcAddress", srcAddress, NULL);
        
        FREObject srcPort;
        FRENewObjectFromUint32(packet.srcPort, &srcPort);
        FRESetObjectProperty(result, (const uint8_t*) "srcPort", srcPort, NULL);
        
        FREObject dstAddress;
        FRENewObjectFromUTF8([packet.dstAddress length], (const uint8_t*) [packet.dstAddress cStringUsingEncoding:NSUTF8StringEncoding], &dstAddress);
        FRESetObjectProperty(result, (const uint8_t*) "dstAddress", dstAddress, NULL);
        
        FREObject dstPort;
        FRENewObjectFromUint32(packet.dstPort, &dstPort);
        FRESetObjectProperty(result, (const uint8_t*) "dstPort", dstPort, NULL);
    }
    //release it
    packet = nil;
    //return the result
    return result;
}

FREObject Close(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    UDPSocketAdapter *adapter = getUDPSocketAdapter(argv[0]);
    BOOL success = [adapter close];
    
    FREObject result;
    FRENewObjectFromBool(success, &result);
    
    return result;
}

FREObject InitNativeCode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    NSLog(@"Entering InitNativeCode()");
    
    int nr;
    FREGetObjectAsInt32(argv[0], &nr);
    UDPSocketAdapter *adapter = [[UDPSocketAdapter alloc] initWithContext:ctx];
    [adapterDictionary setObject:adapter forKey:[NSString stringWithFormat:@"%i", nr]];
    return NULL;
}

FREObject DisposeNativeCode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    NSLog(@"Entering DisposeNativeCode()");
    
    int nr;
    FREGetObjectAsInt32(argv[0], &nr);
    [adapterDictionary removeObjectForKey:[NSString stringWithFormat:@"%i", nr]];
    return NULL;
}

FRENamedFunction _Shared_methods[] = {
    { (const uint8_t*) "isSupported", 0, IsSupported },
};

FRENamedFunction _Instance_methods[] = {
    { (const uint8_t*) "initNativeCode", 0, InitNativeCode },
    { (const uint8_t*) "disposeNativeCode", 0, DisposeNativeCode },
    { (const uint8_t*) "send", 0, Send },
    { (const uint8_t*) "bind", 0, Bind },
    { (const uint8_t*) "receive", 0, Receive },
    { (const uint8_t*) "readPacket", 0, ReadPacket },
    { (const uint8_t*) "close", 0, Close }
};

UDPSocketAdapter* getUDPSocketAdapter(FREObject freNr)
{
    int nr;
    FREGetObjectAsInt32(freNr, &nr);
    return [adapterDictionary objectForKey:[NSString stringWithFormat:@"%i", nr]];
}

void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
						uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    
    NSLog(@"Entering ContextInitializer()");
    
    if ( 0 == strcmp( (const char*) ctxType, "shared" ) )
    {
        *numFunctionsToTest = sizeof( _Shared_methods ) / sizeof( FRENamedFunction );
        *functionsToSet = _Shared_methods;
    }
    else
    {
        *numFunctionsToTest = sizeof( _Instance_methods ) / sizeof( FRENamedFunction );
        *functionsToSet = _Instance_methods;
    }
    
    NSLog(@"Exiting ContextInitializer()");
    
}

void ContextFinalizer(FREContext ctx)
{
    
    NSLog(@"Entering ContextFinalizer()");
    NSLog(@"Exiting ContextFinalizer()");
    
	return;
}

void UDPSocketiOSLibraryExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                    FREContextFinalizer* ctxFinalizerToSet)
{
    
    NSLog(@"Entering ExtInitializer()");
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
    *ctxFinalizerToSet = &ContextFinalizer;
    
    adapterDictionary = [[NSMutableDictionary alloc] init];
    
    NSLog(@"Exiting ExtInitializer()");
}


void UDPSocketiOSLibraryExtFinalizer(void* extData) {
    
    NSLog(@"Entering ExtFinalizer()");
    
    adapterDictionary = nil;
    
    NSLog(@"Exiting ExtFinalizer()");
    return;
}