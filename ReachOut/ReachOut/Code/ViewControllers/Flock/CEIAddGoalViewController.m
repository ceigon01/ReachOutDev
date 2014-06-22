//
//  CEIAddGoalViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 21.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddGoalViewController.h"
#import "CEIAlertView.h"

@interface CEIAddGoalViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textFieldCaption;
@property (nonatomic, weak) IBOutlet UILabel *labelDateFrom;
@property (nonatomic, weak) IBOutlet UILabel *labelDateTo;
@property (nonatomic, weak) IBOutlet UIButton *buttonDateFrom;
@property (nonatomic, weak) IBOutlet UIButton *buttonDateTo;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

@property (nonatomic, assign) BOOL showingPickerFrom;
@property (nonatomic, assign) BOOL showingPickerTo;

@end

@implementation CEIAddGoalViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
  self.showingPickerFrom = NO;
  self.showingPickerTo = NO;
  self.isEditing = NO;
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldShouldReturn:)];
  [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  NSLog(@"%@",self);
  
  if (self.isEditing) {
    
    self.textFieldCaption.text = self.goal[@"caption"];
    [self.buttonDateFrom setTitle:self.goal[@"dateFrom"] forState:UIControlStateNormal];
    [self.buttonDateTo setTitle:self.goal[@"dateTo"] forState:UIControlStateNormal];
  }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  
  [self.textFieldCaption resignFirstResponder];
  
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
  
  self.goal[@"caption"] = self.textFieldCaption.text;
}

#pragma mark - Action Handling

- (IBAction)tapButtonDateFrom:(id)sender{
  
  self.showingPickerTo = NO;
  self.showingPickerFrom = YES;
  [self.textFieldCaption resignFirstResponder];
  [self valueChangeDatePicker:self.datePicker];
}

- (IBAction)tapButtonDateTo:(id)sender{
  
  self.showingPickerFrom = NO;
  self.showingPickerTo = YES;
  [self.textFieldCaption resignFirstResponder];
  [self valueChangeDatePicker:self.datePicker];
}

- (IBAction)valueChangeDatePicker:(id)sender{
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateStyle = NSDateFormatterMediumStyle;
  dateFormatter.timeStyle = NSDateFormatterNoStyle;
  
  NSString *dateString = [dateFormatter stringFromDate:self.datePicker.date];
  
  if (self.showingPickerTo) {
    
    self.goal[@"dateTo"] = self.datePicker.date;
    [self.buttonDateTo setTitle:dateString forState:UIControlStateNormal];
  }
  else
    if (self.showingPickerFrom){

      self.goal[@"dateFrom"] = self.datePicker.date;
      [self.buttonDateFrom setTitle:dateString forState:UIControlStateNormal];
    }
}

#pragma mark - Lazy Getters

- (PFObject *)goal{
  
  if (_goal == nil) {
    
    _goal = [PFObject objectWithClassName:@"Goal"];
    self.goal[@"isComplete"] = @NO;
  }
  
  return _goal;
}

@end
