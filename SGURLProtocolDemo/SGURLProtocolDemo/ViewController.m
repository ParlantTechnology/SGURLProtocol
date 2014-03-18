//
//  ViewController.m
//  SGURLProtocolDemo
//
//  Created by Dallin Lauritzen on 3/18/14.
//  Copyright (c) 2014 Parlant Technology Inc. All rights reserved.
//

#import "ViewController.h"
#import "SGURLProtocol.h"
#import "BasicSGURLProtocolAuthHandler.h"
#import "MBProgressHUD.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)loadUrl:(NSString *)urlStr
{
    NSURL *url = [NSURL URLWithString:urlStr];
//    DLog(@"URL: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    DLog(@"Request: %@", request);
    [self.webView loadRequest:request];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SGHTTPURLProtocol registerProtocol];
    [BasicSGURLProtocolAuthHandler registerHandler];
    
    NSString *initialUrl = @"http://www.google.com";
    initialUrl = @"http://browserspy.dk/password.php";
    [self loadUrl:initialUrl];
}

- (void)dealloc
{
    [BasicSGURLProtocolAuthHandler unregisterHandler];
    [SGHTTPURLProtocol unregisterProtocol];
}

- (IBAction)refresh:(id)sender
{
    [self.webView reload];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    DLog(@"Start Load: %@", webView.request);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    ELog(error);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    DLog(@"Finished Load: %@", webView.request);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *url = [[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([url rangeOfString:@"://"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    [textField resignFirstResponder];
    
//    DLog(@"Text: %@", url);
    [self loadUrl:url];
    
    return YES;
}

@end
