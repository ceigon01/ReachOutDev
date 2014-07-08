//
//  CEIGoalTableViewCell.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface CEIGoalTableViewCell : UITableViewCell

- (void)configureWithGoal:(PFObject *)paramGoal mission:(PFObject *)paramMission goalSteps:(NSArray *)paramArrayGoalSteps;

@end
