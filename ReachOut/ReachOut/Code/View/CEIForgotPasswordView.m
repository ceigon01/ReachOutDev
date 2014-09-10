//
//  CEIForgotPasswordView.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 10.09.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIForgotPasswordView.h"
#import "CEIColor.h"

@interface CEIForgotPasswordView ()

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubtitle;
@property (nonatomic, weak) IBOutlet UIButton *buttonCancel;
@property (nonatomic, weak) IBOutlet UIButton *buttonSend;

@end

@implementation CEIForgotPasswordView


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
  
  self.layer.cornerRadius = 8.0f;
  self.layer.masksToBounds = YES;
  self.layer.borderWidth = 1.0f;
  self.layer.borderColor = [CEIColor colorIdle].CGColor;
}

#pragma mark - Action Handling

- (IBAction)tapButtonCancel:(id)paramSender{
  
  if ([self.delegate respondsToSelector:@selector(forgotPasswordViewDidTapCancel:)]) {
    
    [self.delegate forgotPasswordViewDidTapCancel:self];
  }
}

- (IBAction)tapButtonSend:(id)paramSender{

  if ([self.delegate respondsToSelector:@selector(forgotPasswordViewDidTapDone:)]) {
    
    [self.delegate forgotPasswordViewDidTapDone:self];
  }
}

@end
