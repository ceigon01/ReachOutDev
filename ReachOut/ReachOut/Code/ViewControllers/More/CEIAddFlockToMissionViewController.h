//
//  CEIAddFlockToMissionViewController.h
//  ReachOut
//
//  Created by Jason Smith on 23.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFObject;

@interface CEIAddFlockToMissionViewController : CEIBaseViewController

@property (nonatomic, strong) NSMutableArray *arrayFollowersSelected;
@property (nonatomic, strong) PFObject *mission;

@end
