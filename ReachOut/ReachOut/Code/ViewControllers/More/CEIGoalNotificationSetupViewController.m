//
//  CEIGoalNotificationSetupViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 23.08.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIGoalNotificationSetupViewController.h"
#import <Parse/Parse.h>
#import "CEIAlertView.h"
#import "NSDate+Difference.h"
#import "CEIDay.h"

NSString *kKeyGoalLocalNotification = @"kKeyGoalLocalNotification";
NSString *kKeyGoalLocalNotificationDescription = @"kKeyGoalLocalNotificationDescription";

static NSString *const kCustomNotificationText = @"Put custom notification text here.";

@interface CEIGoalNotificationSetupViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labelGoalTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelReminder;
@property (nonatomic, weak) IBOutlet UILabel *labelHoursBefore;
@property (nonatomic, weak) IBOutlet UITextView *textViewCustomDescription;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@end

@implementation CEIGoalNotificationSetupViewController

- (void)viewDidLoad{
  [super viewDidLoad];

#warning TODO: localizations
  self.title = @"Setup";
  
  self.labelGoalTitle.text = self.goal[@"caption"];

  self.textViewCustomDescription.text = [NSString stringWithFormat:@"%@ is due!",self.labelGoalTitle.text];
  self.textViewCustomDescription.layer.borderColor = [CEIColor colorBlue].CGColor;
  self.textViewCustomDescription.layer.borderWidth = 2.0f;
  self.textViewCustomDescription.layer.cornerRadius = 4.0f;
  
  [self.pickerView selectRow:1 inComponent:0 animated:YES];
  [self.pickerView selectRow:1 inComponent:1 animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  
  [self tapButtonReset:nil];
  
  if (self.mission[@"dateBegins"]) {
    
    NSString *time = self.goal[@"time"];
    
    NSInteger hour = [[self pickerView:self.pickerView
                           titleForRow:[self.pickerView
                                        selectedRowInComponent:0]
                          forComponent:0]
                      integerValue];
    
    NSInteger minute = [[self pickerView:self.pickerView
                             titleForRow:[self.pickerView
                                          selectedRowInComponent:1]
                            forComponent:1]
                        integerValue];
    
    NSString *description = [NSString stringWithFormat:@"Goal is due %@, notifies %d:%02d before.",time,hour,minute];
    
    NSDate *goalDate = self.mission[@"dateBegins"];

    NSInteger numberOfDays = [NSDate totalDaysCountForMission:self.mission];
    
    NSArray *daysAvailable = self.goal[@"days"];
    
    NSInteger indexOfSeparator = [time rangeOfString:@":"].location;
    
    NSString *hourString = [time substringToIndex:indexOfSeparator];
    NSString *minutesString = [time substringWithRange:NSMakeRange(indexOfSeparator+1, 2)];
    
    NSInteger hourValue = [hourString integerValue];
    NSInteger minutesValue = [minutesString integerValue];
    
    for (NSInteger day = 0; day < numberOfDays; day++) {
      
      NSString *dayName = [CEIDay dayNameWithDayNumber:day];
      
      if ([daysAvailable indexOfObject:dayName] != NSNotFound || [self.goal[@"isRecurring"] boolValue]) {
      
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        localNotification.userInfo = @{
                                       kKeyGoalLocalNotification : self.goal.objectId,
                                       kKeyGoalLocalNotificationDescription : description,
                                       };
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        
        dateComponents.day = day;
        dateComponents.hour = hourValue - hour;
        dateComponents.minute = minutesValue - minute;
        
        NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                                     toDate:goalDate
                                                                    options:NSCalendarWrapComponents];
        
        localNotification.fireDate = date;
        
        localNotification.alertBody = self.textViewCustomDescription.text;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
      }
    }
  }
  else{
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Mission does not have a begin date!"];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  [super touchesBegan:touches withEvent:event];
  
  [self.textViewCustomDescription resignFirstResponder];
}

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
  
  textView.text = @"";
  textView.textColor = [UIColor blackColor];
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
  
  [self textViewDidChange:textView];
}

- (void)textViewDidChange:(UITextView *)textView{
  
  if (textView.text.length == 0){
    
    textView.textColor = [UIColor lightGrayColor];
    textView.text = kCustomNotificationText;
  }
}

#pragma mark - UIPickerView Datasource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
  
  //hours & minutes
  return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
  
  
  if (component == 0) {
    //hours
    
    return 13;
  }
  else{
    //minutes
    
    return 61;
  }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
  
  if (row == 0) {
    
    if (component == 0) {
      
      return @"Hours";
    }
    else{
      
      return @"Minutes";
    }
  }
  
  return [NSString stringWithFormat:@"%d",(row-1)];
}

#pragma mark - Action Handling

- (IBAction)tapButtonReset:(id)sender{
  
  [[[UIApplication sharedApplication] scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *localNotification, NSUInteger idx, BOOL *stop) {
    
    if ([[localNotification.userInfo objectForKey:kKeyGoalLocalNotification] isEqualToString:self.goal.objectId]) {
      
      [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
    }
  }];
}

@end
