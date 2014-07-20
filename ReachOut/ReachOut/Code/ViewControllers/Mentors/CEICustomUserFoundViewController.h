//
//  CEICustomUserFoundViewController.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 17.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFUser;

@interface CEICustomUserFoundViewController : CEIBaseViewController

@property (nonatomic, assign) BOOL isMentor;
@property (nonatomic, copy) NSString *mobileNumber;
@property (nonatomic, strong) PFUser *user;

@end
