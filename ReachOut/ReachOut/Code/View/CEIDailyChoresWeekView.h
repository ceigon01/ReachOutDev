//
//  CEIDailyChoresWeekView.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 08.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEIDailyChoresView.h"


extern const NSInteger kNumberOfDaysInWeek;

@class CEIDailyChoresWeekView;

@protocol CEIDailyChoresWeekViewDelegate <NSObject>

- (void)dailyChoresWeekView:(CEIDailyChoresWeekView *)paramDailyChoresWeekView didTapDailyChoresView:(CEIDailyChoresView *)paramDailyChoresView;

@end

@interface CEIDailyChoresWeekView : UIView

@property (nonatomic, weak) id<CEIDailyChoresWeekViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *arrayGoalSteps;

- (void)configureWithArrayGoalSteps:(NSArray *)arrayGoalSteps;

@end
