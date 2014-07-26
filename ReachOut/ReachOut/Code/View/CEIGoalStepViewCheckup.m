//
//  CEIGoalStepViewCheckup.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 08.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIGoalStepViewCheckup.h"
#import "CEIColor.h"

@implementation CEIGoalStepViewCheckup

- (instancetype)initWithFrame:(CGRect)frame{
  
  self = [super initWithFrame:frame];
  if (self) {
  
    [self setup];
  }
  return self;
}

- (void)awakeFromNib{
  [super awakeFromNib];
  
  [self setup];
}

- (void)setup{
  
  self.layer.cornerRadius = 4.0f;
  self.layer.masksToBounds = YES;
  self.layer.borderWidth = 1.0f;
  self.layer.borderColor = [CEIColor colorBlue].CGColor;
}

#pragma mark - Action Handling

- (IBAction)tapButtonEncourage:(id)paramSender{
  
  [self.delegate goalStepViewCheckupDidTapEncourage:self];
}

- (IBAction)tapButtonDone:(id)paramSender{
  
  [self.delegate goalStepViewCheckupDidTapDone:self];
}

@end
