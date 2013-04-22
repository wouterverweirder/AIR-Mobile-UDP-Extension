//
//  UDPSocketiOSLibrary.h
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 07/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import "UDPSocketAdapter.h"

FREObject IsSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject Send(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject Bind(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject Receive(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject ReadPacket(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject InitNativeCode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject Close(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

UDPSocketAdapter* getUDPSocketAdapter(FREContext ctx);

void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
						uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void ContextFinalizer(FREContext ctx);

void UDPSocketiOSLibraryExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                    FREContextFinalizer* ctxFinalizerToSet);
void UDPSocketiOSLibraryExtFinalizer(void* extData);