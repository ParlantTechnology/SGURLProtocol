//
//  BasicSGURLProtocolAuthHandler.h
//  SGURLProtocolDemo
//
//  Created by Dallin Lauritzen on 3/18/14.
//  Copyright (c) 2014 Parlant Technology Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SGURLProtocol.h"

@interface BasicSGURLProtocolAuthHandler : NSObject <SGHTTPURLProtocolDelegate, UIAlertViewDelegate>

@property (nonatomic) BOOL allowUntrustedHosts;
@property (nonatomic) NSURLCredentialPersistence persistence;
@property (nonatomic, strong) NSString *loginAlertMessageFormat;

+ (BasicSGURLProtocolAuthHandler *)registerHandler;
+ (void)unregisterHandler;

@end
