//
//  CEIAddGoalViewController.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 21.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"
#import <Parse/Parse.h>

@interface CEIAddGoalViewController : CEIBaseViewController

@property (nonatomic, strong) PFObject *goal;
@property (nonatomic, assign) BOOL isEditing;

@end
