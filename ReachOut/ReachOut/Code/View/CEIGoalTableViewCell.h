//
//  CEIGoalTableViewCell.h
//  ReachOut
//
//  Created by Jason Smith on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;
@class CEIGoalTableViewCell;
@class CEIDailyChoresView;

@protocol CEIGoalTableViewCellDelegate <NSObject>

- (void)goalTableViewCell:(CEIGoalTableViewCell *)paramGoalTableViewCell didTapDailyChoresView:(CEIDailyChoresView *)paramDailyChoresView;

@end

@interface CEIGoalTableViewCell : UITableViewCell

@property (nonatomic, weak) id<CEIGoalTableViewCellDelegate> delegateGoalStep;
@property (nonatomic, strong) PFObject *goal;

- (void)configureWithGoal:(PFObject *)paramGoal mission:(PFObject *)paramMission arrayGoalSteps:(NSArray *)paramGoalSteps;

@end
