//
//  CEIAddGoalViewController.h
//  ReachOut
//
//  Created by Jason Smith on 29.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFObject;

@interface CEIAddGoalViewController : CEIBaseViewController

@property (nonatomic, strong) PFObject *goalAdded;
@property (nonatomic, assign, getter = isEditing) BOOL editing;
@property (nonatomic, strong) NSMutableArray *arrayButtonNamesSelected;

@end
