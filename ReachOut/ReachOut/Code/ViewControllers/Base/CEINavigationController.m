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
  
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance] setBarTintColor:[CEIColor colorDarkBlue]];
#warning TODO: check the font
  [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                          NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f],
                                                          }];
  
  [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
  self.navigationBar.translucent = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
  
  return UIStatusBarStyleLightContent;
}

@end
