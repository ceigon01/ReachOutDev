//
//  CEIGoalStepViewCheckin.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 08.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIGoalStepViewCheckin.h"
#import "CEIColor.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger kMaxTextLength = 140;

@interface CEIGoalStepViewCheckin () <UITextViewDelegate>

@end

@implementation CEIGoalStepViewCheckin

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
  
#warning TODO: localization
  self.textView.text = @"Do you have anything in mind?";
  self.textView.textColor = [UIColor lightGrayColor];
  self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.textView.layer.borderWidth = 0.5f;
  self.textView.layer.cornerRadius = 4.0f;
}

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
  
  textView.text = @"";
  textView.textColor = [UIColor blackColor];
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
  
  [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
  
  //is backspace
  const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
  int isBackSpace = strcmp(_char, "\b");
  if (isBackSpace == -8){

    return YES;
  }
  
  return (textView.text.length + range.length) < kMaxTextLength;
}

- (void)textViewDidChange:(UITextView *)textView{
  
#warning TODO: localization
  self.labelGoalCharactersRemaining.text = [NSString stringWithFormat:@"%d characters remaining",kMaxTextLength - textView.text.length];
  
  if (textView.text.length == 0){
    
    textView.textColor = [UIColor lightGrayColor];
    textView.text = @"Do you have anything in mind?";
    [textView resignFirstResponder];
  }
}

#pragma mark - Action Handling

- (IBAction)tapButtonYes:(id)sender{
  
  self.doneSelected = YES;
  self.done = YES;

  self.buttonNo.backgroundColor = [UIColor clearColor];
  self.buttonYes.backgroundColor = [CEIColor colorGreen];
}

- (IBAction)tapButtonNo:(id)sender{
  
  self.doneSelected = YES;
  self.done = NO;
  
  self.buttonYes.backgroundColor = [UIColor clearColor];
  self.buttonNo.backgroundColor = [CEIColor colorRed];
}

- (IBAction)tapButtonCancel:(id)sender{

  [self.delegate goalStepViewCheckinDidTapCancel:self];
}

- (IBAction)tapButtonDone:(id)sender{

  [self.delegate goalStepViewCheckinDidTapDone:self];
}

@end
