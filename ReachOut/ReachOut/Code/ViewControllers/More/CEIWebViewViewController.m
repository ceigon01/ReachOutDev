//
//  CEIWebViewViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIWebViewViewController.h"
#import "MBProgressHUD.h"

@interface CEIWebViewViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation CEIWebViewViewController

- (void)loadURL:(NSURL *)paramURL withTitle:(NSString *)paramTitle{
 
  self.title = paramTitle;
  self.url = paramURL;
}

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
  self.progressHUD = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
  self.progressHUD.labelText = [NSString stringWithFormat:@"Loading %@",self.title];
}

#pragma mark - Action Handling

- (IBAction)tapButtonBack:(id)sender{
  
  [self.webView goBack];
}

- (IBAction)tapButtnNext:(id)sender{
  
  [self.webView goForward];
}

- (IBAction)tapButtonRefresh:(id)sender{
  
  [self.webView reload];
  self.progressHUD = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
  self.progressHUD.labelText = [NSString stringWithFormat:@"Loading %@",self.title];
}

#pragma mark - UIWebView Delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
  
#warning TODO: localizations
  [[[UIAlertView alloc] initWithTitle:@"Error"
                              message:[error localizedDescription]
                             delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
 
  [self.progressHUD hide:YES];
  self.progressHUD = nil;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
  
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
  
  return YES;
}

@end
