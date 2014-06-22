//
//  CEIAddMissionViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 21.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddMissionViewController.h"
#import <Parse/Parse.h>
#import "CEIAddGoalViewController.h"
#import "CEIAlertView.h"
#import "CEIMissionsViewController.h"

static NSString *const kIdentifierCellAddMission = @"kIdentifierCellAddMission";
static NSString *const kIdentifierSegueAddMissionToAddGoalWithEdit = @"kIdentifierSegueAddMissionToAddGoalWithEdit";

@interface CEIAddMissionViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *textFieldMissionCaption;
@property (nonatomic, weak) IBOutlet UIButton *buttonStartTheMission;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation CEIAddMissionViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueAddMissionToAddGoalWithEdit]) {
    
    NSLog(@"%@",((CEIAddGoalViewController *)segue.destinationViewController));
    
    ((CEIAddGoalViewController *)segue.destinationViewController).isEditing = YES;
    ((CEIAddGoalViewController *)segue.destinationViewController).goal = [self.arrayGoals objectAtIndex:self.selectedIndexPath.row];
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{

  [self.textFieldMissionCaption resignFirstResponder];
  
#warning TODO: localizations
  CEIAddGoalViewController *vc = nil;
  
  if ([fromViewController isKindOfClass:[CEIAddGoalViewController class]]) {

    vc = (CEIAddGoalViewController *)fromViewController;
  }
  else
    if ([fromViewController isKindOfClass:[CEIAddMissionViewController class]]){
    
//      [CEIAlertView showAlertViewWithValidationMessage:@"Please fill in all the fields"];
      return NO;
    }
  
  if (vc.goal[@"caption"] == nil) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put a Caption"];
    return NO;
  }
  else
    if (vc.goal[@"dateFrom"] == nil ||
        vc.goal[@"dateTo"] == nil){
      
      [CEIAlertView showAlertViewWithValidationMessage:@"Please put both dates"];
      return NO;
    }
    else
      if ([vc.goal[@"dateFrom"] timeIntervalSince1970] > [vc.goal[@"dateTo"] timeIntervalSince1970]) {
        
        [CEIAlertView showAlertViewWithValidationMessage:@"Date \'from\' has to be earlier then date \'to\'"];
        return NO;
      }
  
  return YES;
}

- (IBAction)unwindAddGoal:(UIStoryboardSegue *)unwindSegue{
  
  if ([unwindSegue.sourceViewController isKindOfClass:[CEIAddGoalViewController class]]) {

    CEIAddGoalViewController *addGoalViewController = ((CEIAddGoalViewController *)unwindSegue.sourceViewController);
    
    PFObject *goal = addGoalViewController.goal;
    
    if (!addGoalViewController.isEditing) {
      
      [goal setObject:self.mission forKey:@"mission"];
      [self.arrayGoals addObject:goal];
    }
    
    __weak CEIAddMissionViewController *weakSelf = self;
    [goal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      
      [weakSelf.tableView reloadData];
    }];
  }
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayGoals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellAddMission
                                                          forIndexPath:indexPath];
  
  PFObject *goal = [self.arrayGoals objectAtIndex:indexPath.row];
  
  cell.textLabel.text = goal[@"caption"];
  
  NSDate *dateFrom = goal[@"dateFrom"];
  NSDate *dateTo = goal[@"dateTo"];
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateStyle = NSDateFormatterMediumStyle;
  dateFormatter.timeStyle = NSDateFormatterNoStyle;
  
  cell.detailTextLabel.text = [NSString stringWithFormat:@"from: %@ to: %@",[dateFormatter stringFromDate:dateFrom],[dateFormatter stringFromDate:dateTo]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [self textFieldShouldReturn:self.textFieldMissionCaption];
  
  self.selectedIndexPath = indexPath;
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action handling

- (IBAction)tapButtonStartTheMission:(id)sender{
  
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  
  [self.textFieldMissionCaption resignFirstResponder];
  
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
  
  self.mission[@"caption"] = self.textFieldMissionCaption.text;
  
  return YES;
}

#pragma mark - Lazy Getters

- (NSMutableArray *)arrayGoals{
  
  if (_arrayGoals == nil) {
    
    _arrayGoals = [[NSMutableArray alloc] init];
  }
  
  return _arrayGoals;
}

- (PFObject *)mission{
  
  if (_mission == nil) {
    
    _mission = [PFObject objectWithClassName:@"Mission"];
  }
  
  return _mission;
}

@end
