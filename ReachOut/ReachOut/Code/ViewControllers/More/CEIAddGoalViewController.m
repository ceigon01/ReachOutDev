//
//  CEIAddGoalViewController.m
//  ReachOut
//
//  Created by Jason Smith on 29.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddGoalViewController.h"
#import "CEIDay.h"
#import "CEIColor.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "CEIAlertView.h"
#import "CEINotificationNames.h"

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
  
  if (self.isEditing) {

    self.arrayButtonNamesSelected = [NSMutableArray arrayWithArray:self.goalAdded[@"days"]];
  }
  
  for (NSInteger dayNumber = 1; dayNumber <= kNumerbOfDayButtons; dayNumber++) {
    
    UIButton *button = (UIButton *)[self.view viewWithTag:(dayNumber + kTagOffsetButtonDay)];
    button.layer.borderColor = [CEIColor colorPurpleText].CGColor;
    button.layer.borderWidth = 1.0f;
    [button setTitle:[CEIDay dayNameWithDayNumber:dayNumber] forState:UIControlStateNormal];
    [button setTitle:[CEIDay dayNameWithDayNumber:dayNumber] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(tapButtonDay:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isEditing) {
      
      if ([self.arrayButtonNamesSelected indexOfObject:[CEIDay dayNameWithDayNumber:dayNumber]] != NSNotFound) {
        
        button.backgroundColor = [CEIColor colorPurpleText];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      }
    }
    
    [self.arrayButtonsDays addObject:button];
  }
  
  self.textViewTitle.layer.borderWidth = 0.5f;
  self.textViewTitle.layer.cornerRadius = 4.0f;
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
  [self.view addGestureRecognizer:tapGestureRecognizer];
  
  if (self.isEditing) {
    
    self.textViewTitle.text = self.goalAdded[@"caption"];
    [self.buttonTime setTitle:self.goalAdded[@"time"] forState:UIControlStateNormal];
    if ([self.goalAdded[@"isRecurring"] boolValue ]) {
      
      self.switchRepeatEveryday.on = YES;
      [self tapSwitch:nil];
    }
  }
  else{
    
    self.textViewTitle.text = @"Put your goal caption here.";
    self.textViewTitle.textColor = [UIColor lightGrayColor];
    self.textViewTitle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.buttonTime setTitle:@"12:00 AM" forState:UIControlStateNormal];
    self.goalAdded[@"time"] = @"12:00 AM";
    
    self.switchRepeatEveryday.on = YES;
    [self tapSwitch:nil];
  }
  
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  
  PFObject *goal = self.goalAdded;
  
  NSString *caption = goal[@"caption"];
  if (caption.length < 1) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put a caption."];
    return;
  }
  
  NSArray *arrayDays = self.arrayButtonNamesSelected;
  BOOL isRecurring = [goal[@"isRecurring"] boolValue];
  if (!isRecurring && arrayDays.count == 0) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Select days you want the goal to take place, or press 'repeat everyday'."];
    return;
  }
  
  [arrayDays enumerateObjectsUsingBlock:^(NSString *dayName, NSUInteger idx, BOOL *stop) {
    
    [goal addUniqueObject:dayName forKey:@"days"];
  }];
  
  if (self.isEditing) {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameGoalEdited object:self.goalAdded];
  }
  else{
   
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameGoalAdded object:self.goalAdded];
  }
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
    textView.textColor = [CEIColor colorPurpleText];
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

    if ([self.arrayButtonNamesSelected indexOfObject:[button titleForState:button.state]] == NSNotFound) {
      
      [self.arrayButtonNamesSelected addObject:[button titleForState:button.state]];
      button.backgroundColor = [CEIColor colorPurpleText];
      [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else{

      [self.arrayButtonNamesSelected removeObject:[button titleForState:button.state]];
      button.backgroundColor = [UIColor whiteColor];
      [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
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

- (NSMutableArray *)arrayButtonNamesSelected{
  
  if (_arrayButtonNamesSelected == nil) {
    
    _arrayButtonNamesSelected = [[NSMutableArray alloc] init];
  }
  
  return _arrayButtonNamesSelected;
}

@end
