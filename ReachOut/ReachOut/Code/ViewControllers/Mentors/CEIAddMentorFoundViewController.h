//
//  CEIAddMentorFoundViewController.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 03.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFUser;

@interface CEIAddMentorFoundViewController : CEIBaseViewController

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, strong) PFUser *userMentor;

@end
