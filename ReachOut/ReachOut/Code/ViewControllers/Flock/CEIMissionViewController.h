//
//  CEIMissionViewController.h
//  ReachOut
//
//  Created by Jason Smith on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFObject;

@interface CEIMissionViewController : CEIBaseViewController

@property (nonatomic, strong) PFObject *mission;
@property (nonatomic, strong) PFObject *user;
@property (nonatomic, assign, getter=isMentor) BOOL mentor;

- (void)refresh;

@end
