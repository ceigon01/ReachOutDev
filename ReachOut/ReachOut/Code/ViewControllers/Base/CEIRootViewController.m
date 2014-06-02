//
//  CEIRootViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIRootViewController.h"

static NSString *const kSegueIdentifierRootSignup = @"kSegueIdentifier_Root_Signup";

@interface CEIRootViewController ()

@end

@implementation CEIRootViewController

- (void)viewDidLoad{
	[super viewDidLoad];
	
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
#warning TODO: check if we are registered
	[self performSegueWithIdentifier:kSegueIdentifierRootSignup sender:self];
}

#pragma mark - Navigation

- (IBAction)unwindRegistration:(UIStoryboardSegue *)unwindSegue{
	
}

@end
