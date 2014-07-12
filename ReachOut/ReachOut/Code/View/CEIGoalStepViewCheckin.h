//
//  CEIGoalStepViewCheckin.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 08.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CEIGoalStepViewCheckin;

@protocol CEIGoalStepViewCheckinDelegate <NSObject>

- (void)goalStepViewCheckinDidTapDone:(CEIGoalStepViewCheckin *)paramGoalStepViewCheckin;
- (void)goalStepViewCheckinDidTapCancel:(CEIGoalStepViewCheckin *)paramGoalStepViewCheckin;

@end

@interface CEIGoalStepViewCheckin : UIView

@property (nonatomic, weak) id<CEIGoalStepViewCheckinDelegate> delegate;
@property (nonatomic, assign, getter=isDoneSelected) BOOL doneSelected;
@property (nonatomic, assign, getter=isDone) BOOL done;

@property (nonatomic, weak) IBOutlet UILabel *labelGoalTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelGoalOr;
@property (nonatomic, weak) IBOutlet UILabel *labelGoalCharactersRemaining;

@property (nonatomic, weak) IBOutlet UIButton *buttonYes;
@property (nonatomic, weak) IBOutlet UIButton *buttonNo;
@property (nonatomic, weak) IBOutlet UIButton *buttonCancel;
@property (nonatomic, weak) IBOutlet UIButton *buttonDone;

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end
