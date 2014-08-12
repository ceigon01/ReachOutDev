//
//  CEIAddMissionViewController.h
//  ReachOut
//
//  Created by Jason Smith on 21.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"
#import <Parse/Parse.h>

@interface CEIAddMissionViewController : CEIBaseViewController

@property (nonatomic, strong) PFObject *mission;
@property (nonatomic, strong) NSMutableArray *arrayGoals;
@property (nonatomic, strong) NSMutableArray *arrayFlock;
@property (nonatomic, assign) BOOL isEditing;

@end
