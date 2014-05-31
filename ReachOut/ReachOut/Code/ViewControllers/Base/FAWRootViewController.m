//
//  FAWRootViewController.m
//  ReachOut
//
//  Created by czesio on 31.05.2014.
//  Copyright (c) 2014 Far and Wide. All rights reserved.
//

#import "FAWRootViewController.h"

static NSString *const kSegueIdentifierRootSignup = @"kSegueIdentifierRootSignup";

@interface FAWRootViewController ()

@end

@implementation FAWRootViewController
	
- (void)viewDidLoad{
	
#warning TODO: check if we are registered
	
	[self performSegueWithIdentifier:kSegueIdentifierRootSignup sender:self];
}

@end
