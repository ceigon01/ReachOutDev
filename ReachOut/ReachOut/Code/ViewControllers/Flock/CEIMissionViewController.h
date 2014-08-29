//
//  CEIMissionViewController.h
//  ReachOut
//
//  Created by Jason Smith on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFObject;
@class PFUser;

@interface CEIMissionViewController : CEIBaseViewController

@property (nonatomic, strong) PFObject *mission;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign, getter=isMentor) BOOL mentor;

- (void)refresh;

@end
