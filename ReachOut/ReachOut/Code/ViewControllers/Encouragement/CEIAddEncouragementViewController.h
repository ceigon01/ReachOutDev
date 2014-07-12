//
//  CEIAddEncouragementViewController.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"
#import <Parse/Parse.h>

@interface CEIAddEncouragementViewController : CEIBaseViewController

@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, strong) NSArray *arrayFollowers;
@property (nonatomic, strong) NSIndexPath *indexPathSelectedFollower;

@property (nonatomic, strong) PFObject *folowerSelected;

@end
