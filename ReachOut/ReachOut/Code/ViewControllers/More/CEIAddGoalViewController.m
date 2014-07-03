//
//  CEIAddGoalViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 29.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddGoalViewController.h"
#import "CEIDay.h"
#import "CEIColor.h"
#import <Parse/Parse.h>

static const NSUInteger kTagOffsetButtonDay = 1000;
static const NSUInteger kNumerbOfDayButtons = 7;

@interface CEIAddGoalViewController () <UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSMutableArray *arrayButtonsDays;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelBefore;
@property (weak, nonatomic) IBOutlet UITextView *textViewTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelRepeatEveryday;
@property (weak, nonatomic) IBOutlet UISwitch *switchRepeatEveryday;
@property (weak, nonatomic) IBOutlet UILabel *labelDaysOfWeek;
@property (weak, nonatomic) IBOutlet UIButton *buttonMon;
@property (weak, nonatomic) IBOutlet UIButton *buttonTue;
@property (weak, nonatomic) IBOutlet UIButton *buttonWed;
@property (weak, nonatomic) IBOutlet UIButton *buttonThu;
@property (weak, nonatomic) IBOutlet UIButton *buttonFri;
@property (weak, nonatomic) IBOutlet UIButton *buttonSat;
@property (weak, nonatomic) IBOutlet UIButton *buttonSun;
@property (weak, nonatomic) IBOutlet UIPickerView *datePickerView;
@property (weak, nonatomic) IBOutlet UIButton *buttonTime;

@end

@implementation CEIAddGoalViewController

- (void)viewDidLoad{
  [super viewDidLoad];

#warning TODO: localization
  self.title = @"Add a Goal";
  
  for (NSInteger dayNumber = 0; dayNumber < kNumerbOfDayButtons; dayNumber++) {
    
    UIButton *button = (UIButton *)[self.view viewWithTag:(dayNumber + kTagOffsetButtonDay)];
    
    [button setTitle:[CEIDay dayNameWithDayNumber:dayNumber] forState:UIControlStateNormal];
    [button setTitle:[CEIDay dayNameWithDayNumber:dayNumber] forState:UIControlStateSelected];
    button.backgroundColor = [CEIColor colorIdle];
    [button addTarget:self action:@selector(tapButtonDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.arrayButtonsDays addObject:button];
  }
  
  self.textViewTitle.text = @"Put your goal caption here.";
  self.textViewTitle.textColor = [UIColor lightGrayColor];
  self.textViewTitle.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.textViewTitle.layer.borderWidth = 0.5f;
  self.textViewTitle.layer.cornerRadius = 4.0f;
  
  self.switchRepeatEveryday.on = NO;
  [self.buttonTime setTitle:@"12:00 AM" forState:UIControlStateNormal];
  self.goalAdded[@"time"] = @"12:00 AM";
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
  [self.view addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
  
}

- (void)textViewDidEndEditing:(UITextView *)textView{
  
  [textView resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
  
  textView.text = @"";
  textView.textColor = [UIColor blackColor];
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
  
  if (textView.text.length == 0){
    
#warning TODO: localization
    textView.textColor = [UIColor lightGrayColor];
    textView.text = @"Put your goal caption here.";
    [textView resignFirstResponder];
  }
  
  self.goalAdded[@"caption"] = textView.text;
}

#pragma mark - Action Handling

- (void)tapGesture:(id)paramSender{
  
  [self.textViewTitle resignFirstResponder];
}

- (IBAction)tapButtonTime:(id)paramSender{
  
  [self.textViewTitle resignFirstResponder];
}

- (void)tapButtonDay:(id)paramSender{
  
  if ([paramSender isKindOfClass:[UIButton class]]) {
    
    UIButton *button = (UIButton *)paramSender;
    
    button.selected = !button.selected;
    
    if (button.selected) {
      
      [self.goalAdded addUniqueObject:[button titleForState:button.state] forKey:@"days"];
      button.backgroundColor = [CEIColor greenColor];
    }
    else{

      [self.goalAdded removeObject:[button titleForState:button.state] forKey:@"days"];
      button.backgroundColor = [CEIColor colorIdle];
    }
  }
}

- (IBAction)tapSwitch:(id)sender{
  
  __weak CEIAddGoalViewController *weakSelf = self;
  
  [self.arrayButtonsDays enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
    
    button.enabled = !weakSelf.switchRepeatEveryday.on;
  }];
  
  self.goalAdded[@"isRecurring"] = [NSNumber numberWithBool:self.switchRepeatEveryday.on];
}
  
#pragma mark - UIDatePickerView Delegate & Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
  
  return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
  
  if (component == 0) {
    
    return 12;
  }
  else{
    
    return 2;
  }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
  
  if (component == 0) {

    return [NSString stringWithFormat:@"%d:00",[self pickerView:pickerView numberOfRowsInComponent:component] - row];
  }
  else{
    if (row == 0) {
      
      return @"AM";
    }
    else{
      
      return @"PM";
    }
  }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
  
  NSString *time = [self pickerView:self.datePickerView
                        titleForRow:[self.datePickerView selectedRowInComponent:0]
                       forComponent:0];
  
  NSString *season = [self pickerView:self.datePickerView
                          titleForRow:[self.datePickerView selectedRowInComponent:1]
                         forComponent:1];
  
  self.goalAdded[@"time"] = [NSString stringWithFormat:@"%@ %@",time,season];
  [self.buttonTime setTitle:self.goalAdded[@"time"] forState:UIControlStateNormal];
}

#pragma mark - Lazy Getters

- (NSMutableArray *)arrayButtonsDays{
  
  if (_arrayButtonsDays == nil) {
    
    _arrayButtonsDays = [[NSMutableArray alloc] init];
  }
  
  return _arrayButtonsDays;
}

- (PFObject *)goalAdded{
  
  if (_goalAdded == nil) {
    
    _goalAdded = [PFObject objectWithClassName:@"Goal"];
  }
  
  return _goalAdded;
}

@end