//
//  CEIGoalStepViewCheckup.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 08.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CEIGoalStepViewCheckup;

@protocol CEIGoalStepViewCheckupDelegate <NSObject>

- (void)goalStepViewCheckupDidTapDone:(CEIGoalStepViewCheckup *)paramGoalStepViewCheckup;
- (void)goalStepViewCheckupDidTapEncourage:(CEIGoalStepViewCheckup *)paramGoalStepViewCheckup;

@end

@interface CEIGoalStepViewCheckup : UIView

@property (nonatomic, weak) id<CEIGoalStepViewCheckupDelegate> delegate;

@property (nonatomic, weak) IBOutlet UILabel *labelDay;
@property (nonatomic, weak) IBOutlet UILabel *labelDone;
@property (nonatomic, weak) IBOutlet UILabel *labelGoalTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelResponseTime;

@property (nonatomic, weak) IBOutlet UIButton *buttonEncourage;
@property (nonatomic, weak) IBOutlet UIButton *buttonDone;

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end
