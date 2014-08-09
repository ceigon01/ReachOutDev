//
//  CEIGoalStepViewCheckin.m
//  ReachOut
//
//  Created by Jason Smith on 08.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIGoalStepViewCheckin.h"
#import "CEIColor.h"
#import <QuartzCore/QuartzCore.h>

#warning TODO: localization
static NSString *const kTextViewTextPlaceholder = @"Do you have anything in mind?";
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
  self.layer.borderWidth = 2.0f;
  self.layer.borderColor = [CEIColor colorBlue].CGColor;
  
  self.textView.text = kTextViewTextPlaceholder;
  self.textView.textColor = [UIColor lightGrayColor];
  self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.textView.layer.borderWidth = 1.0f;
  
//  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                         action:@selector(tapGesture:)];
//  tapGestureRecognizer.numberOfTapsRequired = 1;
//  [self addGestureRecognizer:tapGestureRecognizer];

  self.labelGoalCharactersRemaining.text = [NSString stringWithFormat:@"%d characters remaining",kMaxTextLength];
}

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
  
  self.labelGoalCharactersRemaining.text = [NSString stringWithFormat:@"%d characters remaining",kMaxTextLength];
  textView.text = @"";
  textView.textColor = [UIColor blackColor];
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
  
  [self textViewDidChange:textView];
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
    self.labelGoalCharactersRemaining.text = [NSString stringWithFormat:@"%d characters remaining",kMaxTextLength];
  }
}

#pragma mark - Action Handling

//- (void)tapGesture:(id)sender{
//  
//  [self.textView resignFirstResponder];
//}

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
