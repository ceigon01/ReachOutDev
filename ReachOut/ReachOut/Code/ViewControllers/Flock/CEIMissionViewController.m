//
//  CEIMissionViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMissionViewController.h"
#import "CEIGoalTableViewCell.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "CEIAlertView.h"
#import "NSDate+Difference.h"
#import <Parse/Parse.h>
#import "NSDate+Difference.h"
#import "UIImageView+WebCache.h"
#import "CEIGoalStepViewCheckin.h"
#import "CEIGoalStepViewCheckup.h"
#import "ASDepthModalViewController.h"
#import "CEIDailyChoresView.h"
#import "CEIColor.h"
#import "CEIAddEncouragementViewController.h"

static NSString *const kNibNameCEIGoalStepViewCheckin = @"CEIGoalStepViewCheckin";
static NSString *const kNibNameCEIGoalStepViewCheckup = @"CEIGoalStepViewCheckup";

static NSString *const kIdentifierSegueMissionAddEncouragement = @"kIdentifierSegueMissionAddEncouragement";

static NSString *const kIdentifierCellMission = @"kIdentifierCellMission";
static const CGFloat kHeightFooter = 20.0f;
static const CGFloat kHeightCell = 100.0f;

@interface CEIMissionViewController () <UITableViewDataSource, UITableViewDelegate, CEIGoalStepViewCheckinDelegate, CEIGoalTableViewCellDelegate, CEIGoalStepViewCheckupDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageViewBackgroud;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UILabel *labelUserName;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionName;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionDuration;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *arrayGoals;
@property (nonatomic, strong) NSArray *arrayGoalSteps;

@property (nonatomic, strong) PFObject *encouragementNew;

@property (nonatomic, strong) CEIGoalTableViewCell *selectedCell;
@property (nonatomic, strong) CEIDailyChoresView *selectedDailyChoresView;

@end

@implementation CEIMissionViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [self.tableView registerClass:[CEIGoalTableViewCell class]
         forCellReuseIdentifier:kIdentifierCellMission];
  
  __weak typeof (self) weakSelf = self;
  
  PFFile *file = self.mission[@"image"];
  [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
    
    if (error){
    
    }
    else{
      
      weakSelf.imageViewBackgroud.image = [UIImage imageWithData:data];
    }
  }];

  if (weakSelf.user[@"image"]) {
    
    PFFile *file = weakSelf.user[@"image"];
    
    __weak typeof (self) weakSelf = self;
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
      
      weakSelf.imageViewProfile.image = [UIImage imageWithData:data];
      weakSelf.imageViewProfile.layer.cornerRadius = weakSelf.imageViewProfile.frame.size.height * 0.5f;
      weakSelf.imageViewProfile.layer.masksToBounds = YES;
    }];
    
  }
  else{
    
    self.imageViewProfile.image = [UIImage imageNamed:@"sheepPhoto"];
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.height * 0.5f;
    self.imageViewProfile.layer.masksToBounds = YES;
  }
  
  self.labelMissionDuration.text = self.mission[@"timeCount"];
  self.labelMissionName.text = self.mission[@"caption"];
  self.labelUserName.text = self.user[@"fullName"];
  self.labelMissionDuration.textColor = [UIColor whiteColor];
  self.labelMissionName.textColor = [UIColor whiteColor];
  self.labelUserName.textColor = [UIColor whiteColor];
  
  self.tableView.backgroundColor = [UIColor whiteColor];
  
  [self fetchGoals];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  __weak typeof(self) weakSelf = self;
  [self.tableView addPullToRefreshActionHandler:^{
    
    [weakSelf fetchGoals];
  }
                          ProgressImagesGifName:@"run@2x.gif"
                           LoadingImagesGifName:@"run@2x.gif"
                        ProgressScrollThreshold:60
                          LoadingImageFrameRate:30];
}

- (void)fetchGoals{
  
  __weak CEIMissionViewController *weakSelf = self;
  
  PFQuery *queryGoals = [PFQuery queryWithClassName:@"Goal"];
  if (queryGoals && [PFUser currentUser]) {
    
    [queryGoals whereKey:@"mission" equalTo:self.mission];
    [queryGoals findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayGoals = [NSArray arrayWithArray:objects];
        
#warning TODO: double fetch, not so cool :(
        
        PFQuery *queryGoalSteps = [PFQuery queryWithClassName:@"GoalStep"];
        [queryGoalSteps whereKey:@"mission" equalTo:self.mission];
        [queryGoalSteps includeKey:@"goal"];
        [queryGoalSteps findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          
          [weakSelf.tableView stopRefreshAnimation];
      
          if (error){
            
            [CEIAlertView showAlertViewWithError:error];
          }
          else{
            
            weakSelf.arrayGoalSteps = [NSArray arrayWithArray:objects];
            
            [weakSelf.tableView reloadData];
          }
        }];
      }
    }];
  }
}

#pragma mark - Navigation

- (IBAction)unwindAddEncouragement:(UIStoryboardSegue *)unwindSegue{
  
  if ([unwindSegue.sourceViewController isKindOfClass:[CEIAddEncouragementViewController class]]) {
    
    [self.tableView reloadData];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueMissionAddEncouragement]) {
    
    CEIAddEncouragementViewController *addEncouragementViewController = (CEIAddEncouragementViewController *)segue.destinationViewController;
    
    addEncouragementViewController.folowerSelected = self.user;
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{
  
#warning TODO: localizations
  CEIAddEncouragementViewController *vc = nil;
  
  if ([fromViewController isKindOfClass:[CEIAddEncouragementViewController class]]) {
    
    vc = (CEIAddEncouragementViewController *)fromViewController;
  }
  else {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Shouldn't get here!"];
    return NO;
  }
  
  self.encouragementNew = [PFObject objectWithClassName:@"Encouragement"];
  
  if (vc.textView.text.length == 0) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put an Encouragement"];
    return NO;
  }
  else {
    
    self.encouragementNew[@"caption"] = vc.textView.text;
  }
  
  if (vc.indexPathSelectedFollower == nil) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Select a Follower to Encourage"];
    return NO;
  }
  
  __block PFUser *userFollowerSelected = [vc.arrayFollowers objectAtIndex:vc.indexPathSelectedFollower.row];
  
  self.encouragementNew[@"mentorID"] = [PFUser currentUser];
  self.encouragementNew[@"followerID"] = userFollowerSelected;
  
  [self.encouragementNew saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else {
    }
  }];
  
  return YES;
}

#pragma mark - UITableView Datasource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  return kHeightCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return self.arrayGoals.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIGoalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellMission];
  
  cell.delegateGoalStep = self;
  
  PFObject *goal = [self.arrayGoals objectAtIndex:indexPath.section];
  
  [cell configureWithGoal:goal mission:self.mission goalSteps:[self arrayGoalStepsForGoal:goal]];
  
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
  
  PFObject *goal = [self.arrayGoals objectAtIndex:section];
  
  return goal[@"caption"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
  
  return kHeightFooter;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
  
  PFObject *goal = [self.arrayGoals objectAtIndex:section];
  
  NSArray *arrayGoalSteps = [self arrayGoalStepsForGoal:goal withDone:YES];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             tableView.frame.size.width,
                                                             kHeightFooter)];
  label.textAlignment = NSTextAlignmentRight;
  
#warning TODO: which to use?
//  label.text = [NSString stringWithFormat:@"%.0f %% of goal",([self totalDaysCountForTodayForMission:self.mission] * 100.0f / [self totalDaysCountForMission:self.mission])];
  
  label.text = [NSString stringWithFormat:@"%.0f %% of goal  ",fabs((arrayGoalSteps.count * 100.0f / [NSDate totalDaysCountForMission:self.mission]))];
  
  return label;
}

#pragma mark - Convinience Methods

- (NSArray *)arrayGoalStepsForGoal:(PFObject *)paramGoal{
  
  NSMutableArray *arrayGoalsFiltered = [[NSMutableArray alloc] init];
  
  NSString *goalID = paramGoal.objectId;
  
  [self.arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStep, NSUInteger idx, BOOL *stop) {
    
    NSString *goalIDTest = [goalStep[@"goal"] objectId];
    
    if ([goalID isEqualToString:goalIDTest]){
    
      [arrayGoalsFiltered addObject:goalStep];
    }
  }];
  
  return [NSArray arrayWithArray:arrayGoalsFiltered];
}

- (NSArray *)arrayGoalStepsForGoal:(PFObject *)paramGoal withDone:(BOOL)paramDone{
  
  NSMutableArray *arrayGoalsFiltered = [[NSMutableArray alloc] init];
  
  NSString *goalID = paramGoal.objectId;
  
  [self.arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStep, NSUInteger idx, BOOL *stop) {
    
    NSString *goalIDTest = [goalStep[@"goal"] objectId];
    
    BOOL done = [goalStep[@"done"] boolValue];
    
    if ([goalID isEqualToString:goalIDTest] && done){
      
      [arrayGoalsFiltered addObject:goalStep];
    }
  }];
  
  return [NSArray arrayWithArray:arrayGoalsFiltered];
}

#pragma mark - CEIGoalTableViewCell Delegate

- (void)goalTableViewCell:(CEIGoalTableViewCell *)paramGoalTableViewCell didTapDailyChoresView:(CEIDailyChoresView *)paramDailyChoresView{
  
  self.selectedCell = paramGoalTableViewCell;
  self.selectedDailyChoresView = paramDailyChoresView;
  
  if (self.isMentor) {
    
    CEIGoalStepViewCheckup *goalStepViewCheckup = [[[NSBundle mainBundle] loadNibNamed:kNibNameCEIGoalStepViewCheckup
                                                                                 owner:self
                                                                               options:nil]
                                                   lastObject];
    goalStepViewCheckup.delegate = self;
    
    PFObject *goal = paramGoalTableViewCell.goal;
    PFObject *goalStep = paramDailyChoresView.goalStep;
    
    goalStepViewCheckup.labelGoalTitle.text = goal[@"caption"];
    
    if (goalStep == nil) {
      
      goalStepViewCheckup.textView.text = @"This day for goal is empty, and this view is displayed only due to demo purposes. It won't be active afterwards.";
      
      goalStepViewCheckup.labelDay.text = @"-";
      goalStepViewCheckup.labelDone.text = @"-";
      
    }
    else{
      
      goalStepViewCheckup.textView.text = goalStep[@"caption"];
      
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      dateFormatter.dateStyle = NSDateFormatterShortStyle;
      dateFormatter.timeStyle = NSDateFormatterShortStyle;
      
#warning TODO: improove handling
      goalStepViewCheckup.labelResponseTime.text = [dateFormatter stringFromDate:goalStep.createdAt];
      goalStepViewCheckup.labelDay.text = goalStep[@"day"];
      goalStepViewCheckup.labelDone.text = [goalStep[@"done"] boolValue] ? @"Yes" : @"No";
      
      if ([goalStep[@"done"] boolValue]) {
        
        goalStepViewCheckup.labelDone.backgroundColor = [CEIColor colorGreen];
        goalStepViewCheckup.labelDay.backgroundColor = [CEIColor colorGreen];
      }
      else{
        
        goalStepViewCheckup.labelDone.backgroundColor = [CEIColor colorRed];
        goalStepViewCheckup.labelDay.backgroundColor = [CEIColor colorRed];
      }
      
    }
    
    [ASDepthModalViewController presentView:goalStepViewCheckup
                            backgroundColor:[UIColor whiteColor]
                                    options:ASDepthModalOptionAnimationGrow | ASDepthModalOptionBlur | ASDepthModalOptionTapOutsideToClose
                          completionHandler:NULL];
  }
  else{
   
    CEIGoalStepViewCheckin *goalStepViewCheckin = [[[NSBundle mainBundle] loadNibNamed:kNibNameCEIGoalStepViewCheckin
                                                                                owner:self
                                                                              options:nil]
                                                   lastObject];
    goalStepViewCheckin.delegate = self;
    
    PFObject *goal = paramGoalTableViewCell.goal;
    
    goalStepViewCheckin.labelGoalTitle.text = goal[@"caption"];
    
    [ASDepthModalViewController presentView:goalStepViewCheckin
                            backgroundColor:[UIColor whiteColor]
                                    options:ASDepthModalOptionAnimationGrow | ASDepthModalOptionBlur | ASDepthModalOptionTapOutsideToClose
                          completionHandler:NULL];
  }
}

#pragma mark - CEIGoalStepViewCheckup Delegate

- (void)goalStepViewCheckupDidTapDone:(CEIGoalStepViewCheckup *)paramGoalStepViewCheckup{
  
  [ASDepthModalViewController dismiss];
}

- (void)goalStepViewCheckupDidTapEncourage:(CEIGoalStepViewCheckup *)paramGoalStepViewCheckup{
  
  [ASDepthModalViewController dismiss];
  [self performSegueWithIdentifier:kIdentifierSegueMissionAddEncouragement sender:self];
}

#pragma mark - CEIGoalStepViewCheckin Delegate

- (void)goalStepViewCheckinDidTapDone:(CEIGoalStepViewCheckin *)paramGoalStepViewCheckin{
  
  if (!paramGoalStepViewCheckin.isDoneSelected){
  
    [CEIAlertView showAlertViewWithValidationMessage:@"Please confirim wether you have fulfilled the goal or not."];
    return;
  }
  
  PFObject *goalStep = [PFObject objectWithClassName:@"GoalStep"];
  
  goalStep[@"goal"] = self.selectedCell.goal;
  goalStep[@"caption"] = paramGoalStepViewCheckin.textView.text;
  goalStep[@"done"] = [NSNumber numberWithBool:paramGoalStepViewCheckin.done];
  goalStep[@"mission"] = self.mission;
  goalStep[@"day"] = self.selectedDailyChoresView.dayName;
  
  [self.selectedDailyChoresView configureWithGoalStep:goalStep];
  
  [goalStep saveInBackground];
  
  
  PFQuery *query = [PFInstallation query];
  [query whereKey:@"user" equalTo:self.user];
  
  [PFPush sendPushMessageToQueryInBackground:query withMessage:[NSString stringWithFormat:@"%@: %@ %@",[PFUser currentUser][@"fullName"],paramGoalStepViewCheckin.done ? @"Done:" : @"Didn't do it:",self.selectedCell.goal[@"caption"]]];
  
  [ASDepthModalViewController dismiss];
}

- (void)goalStepViewCheckinDidTapCancel:(CEIGoalStepViewCheckin *)paramGoalStepViewCheckin{

  [ASDepthModalViewController dismiss];
}

@end
