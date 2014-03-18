//
//  BasicSGURLProtocolAuthHandler.m
//  SGURLProtocolDemo
//
//  Created by Dallin Lauritzen on 3/18/14.
//  Copyright (c) 2014 Parlant Technology Inc. All rights reserved.
//

#import "BasicSGURLProtocolAuthHandler.h"

@interface BasicSGURLProtocolAuthHandler ()
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) NSURLAuthenticationChallenge *challenge;
@property (nonatomic, strong) NSURLCredential *credential;
@property (nonatomic) BOOL registered;
@end

static BasicSGURLProtocolAuthHandler * _sharedHandler = nil;

@implementation BasicSGURLProtocolAuthHandler

+ (BasicSGURLProtocolAuthHandler *)registerHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [BasicSGURLProtocolAuthHandler new];
    });
    if (!_sharedHandler.registered) {
        [SGHTTPURLProtocol setProtocolDelegate:_sharedHandler];
        _sharedHandler.registered = YES;
    }
    return _sharedHandler;
}

+ (void)unregisterHandler
{
    [SGHTTPURLProtocol setProtocolDelegate:nil];
    _sharedHandler.registered = NO;
}

- (id)init
{
    if (self = [super init]) {
        self.registered = NO;
        self.allowUntrustedHosts = NO;
        self.persistence = NSURLCredentialPersistenceForSession;
        self.loginAlertMessageFormat = NSLocalizedString(@"Please log in to %@", nil);
    }
    return self;
}

- (void)showLoginAlert
{
    if (self.alertView.isVisible) return;
    
    if (!self.alertView) {
        self.alertView = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Log In", nil), nil];
    }
    
    __weak BasicSGURLProtocolAuthHandler *_self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:self.loginAlertMessageFormat, _self.challenge.protectionSpace.host ?: @""];
        _self.alertView.message = message;
        _self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [[_self.alertView textFieldAtIndex:1] setText:@""]; // Clear Password
        [_self.alertView show];
    });
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self.challenge.sender cancelAuthenticationChallenge:self.challenge];
        return;
    }
    
    NSString *user = [[alertView textFieldAtIndex:0] text];
    NSString *pass = [[alertView textFieldAtIndex:1] text];
    if (!user.length || !pass.length) {
        DLog(@"Username or password not provided.");
        [self showLoginAlert];
        return;
    }
    
    self.credential = [NSURLCredential credentialWithUser:user password:pass persistence:self.persistence];
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:self.credential forProtectionSpace:self.challenge.protectionSpace];
    [self.challenge.sender useCredential:self.credential forAuthenticationChallenge:self.challenge];
}

#pragma mark - SGHTTPURLProtocolDelegate

- (void)URLProtocol:(SGHTTPURLProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
//    NSDictionary *credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:challenge.protectionSpace];
    NSURLCredential *cred = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:challenge.protectionSpace];
    if (cred && challenge.previousFailureCount <= 1) {
        [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
        return;
    }
    
    self.challenge = challenge;
    [self showLoginAlert];
}

- (BOOL)URLProtocol:(SGHTTPURLProtocol *)protocol canIgnoreUntrustedHost:(SecTrustRef)trust
{
    return self.allowUntrustedHosts;
}

@end
