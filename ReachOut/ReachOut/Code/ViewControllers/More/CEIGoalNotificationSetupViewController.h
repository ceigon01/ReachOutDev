//
//  CEIGoalNotificationSetupViewController.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 23.08.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFObject;

extern NSString *kKeyGoalLocalNotification;
extern NSString *kKeyGoalLocalNotificationDescription;

@interface CEIGoalNotificationSetupViewController : CEIBaseViewController

@property (nonatomic, strong) PFObject *goal;
@property (nonatomic, strong) PFObject *mission;

@end
