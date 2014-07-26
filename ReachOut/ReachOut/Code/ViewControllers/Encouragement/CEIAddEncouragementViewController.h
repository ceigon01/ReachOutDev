//
//  CEIAddEncouragementViewController.h
//  ReachOut
//
//  Created by Jason Smith on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"
#import <Parse/Parse.h>

@interface CEIAddEncouragementViewController : CEIBaseViewController

@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, strong) NSMutableArray *arrayFollowersSelected;
@property (nonatomic, strong) NSMutableArray *arrayFollowersAvailable;

@property (nonatomic, assign) BOOL encouragementInPlace;

@end
