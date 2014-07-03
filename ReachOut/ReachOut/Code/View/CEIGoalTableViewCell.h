//
//  CEIGoalTableViewCell.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CEIGoalTableViewCell : UITableViewCell

@property (nonatomic, strong) UIScrollView *scrollView;

- (void)configureWithGoal:(PFObject *)paramGoal;

@end
