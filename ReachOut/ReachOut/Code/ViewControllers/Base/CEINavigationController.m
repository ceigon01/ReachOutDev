//
//  CEINavigationController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEINavigationController.h"
#import "CEIColor.h"

@interface CEINavigationController ()

@end

@implementation CEINavigationController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: check this tint
  [[UINavigationBar appearance] setTintColor:[CEIColor colorDarkBlue]];
  [[UINavigationBar appearance] setBarTintColor:[CEIColor colorDarkBlue]];
  
  [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
  self.navigationBar.translucent = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
  
  return UIStatusBarStyleLightContent;
}

@end
