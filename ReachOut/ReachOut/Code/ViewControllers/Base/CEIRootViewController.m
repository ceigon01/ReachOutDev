//
//  CEIRootViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIRootViewController.h"
#import <Parse/Parse.h>
#import "CEINotificationNames.h"

static NSString *const kSegueIdentifierRootSignup = @"kSegueIdentifier_Root_Signup";

@interface CEIRootViewController ()

@end

@implementation CEIRootViewController

- (void)dealloc{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad{
	[super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleNotificationLogout:)
                                               name:kNotificationNameLogout
                                             object:nil];
  
  APP_DELEGATE.window.backgroundColor = [UIColor whiteColor];
  
#warning TODO: hiding the labels & setting the images insets?
  
  [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *tabBarItem, NSUInteger idx, BOOL *stop) {

    [tabBarItem setImageInsets:UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f)];
    [tabBarItem setTitlePositionAdjustment:UIOffsetMake(0.0f, 300.0f)];
  }];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
  if (![[PFUser currentUser] isAuthenticated]) {
    
  	[self performSegueWithIdentifier:kSegueIdentifierRootSignup sender:self];
  }
}

#pragma mark - Navigation

- (IBAction)unwindRegistration:(UIStoryboardSegue *)unwindSegue{
	
}

- (IBAction)unwindAddUser:(UIStoryboardSegue *)unwindSegue{

}

#pragma mark - Notification Handling

- (void)handleNotificationLogout:(NSNotification *)paramNotification{
  
  [self performSegueWithIdentifier:kSegueIdentifierRootSignup sender:self];
}

@end
