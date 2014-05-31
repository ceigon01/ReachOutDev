//
//  CEIRootViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIRootViewController.h"

static NSString *const kSegueIdentifierRootSignup = @"kSegueIdentifierRootSignup";

@interface CEIRootViewController ()

@end

@implementation CEIRootViewController
	
- (void)viewDidLoad{
	
#warning TODO: check if we are registered
	
	[self performSegueWithIdentifier:kSegueIdentifierRootSignup sender:self];
}

@end
