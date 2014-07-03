//
//  CEIMissionViewController.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFObject;

@interface CEIMissionViewController : CEIBaseViewController

@property (nonatomic, strong) PFObject *mission;
@property (nonatomic, assign, getter=isMentor) BOOL mentor;

@end
