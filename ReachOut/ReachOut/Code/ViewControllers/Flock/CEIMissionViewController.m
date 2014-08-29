//
//  CEIMissionViewController.m
//  ReachOut
//
//  Created by Jason Smith on 11.06.2014.
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
#import "KLCPopup.h"
#import "CEIDailyChoresView.h"
#import "CEIColor.h"
#import "CEIAddEncouragementViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import "CEINotificationNames.h"
#import "CEIAddGoalViewController.h"

static NSString *const kNibNameCEIGoalStepViewCheckin = @"CEIGoalStepViewCheckin";
static NSString *const kNibNameCEIGoalStepViewCheckup = @"CEIGoalStepViewCheckup";

static NSString *const kIdentifierSegueMissionAddEncouragement = @"kIdentifierSegueMissionAddEncouragement";
static NSString *const kIdentifierSegueMissionToAddGoal = @"kIdentifierSegueMissionToAddGoal";

static NSString *const kIdentifierCellMission = @"kIdentifierCellMission";
static const CGFloat kHeightHeader = 25.0f;
static const CGFloat kHeightFooter = 14.0f;
static const CGFloat kHeightCell = 100.0f;

static const NSInteger kTagOffsetLabelTableViewHeader = 1235;

@interface CEIMissionViewController () <UITableViewDataSource, UITableViewDelegate, CEIGoalStepViewCheckinDelegate, CEIGoalTableViewCellDelegate, CEIGoalStepViewCheckupDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageViewBackgroud;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UILabel *labelUserName;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionName;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionDuration;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *arrayGoals;
@property (nonatomic, strong) NSMutableArray *arrayGoalSteps;

@property (nonatomic, strong) CEIGoalTableViewCell *selectedCell;
@property (nonatomic, strong) CEIDailyChoresView *selectedDailyChoresView;

@property (nonatomic, strong) PFObject *goalSelected;

@end

@implementation CEIMissionViewController

- (void)dealloc{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationGoalModified:(NSNotification *)paramNotification{
  
  PFObject *goal = paramNotification.object;
  
  __weak typeof(self) weakSelf = self;
  
  [self.tableView reloadData];
  
  [goal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if (error) {
      
      [weakSelf.tableView reloadData];
      [CEIAlertView showAlertViewWithError:error];
    }
    else{
      
      [weakSelf fetchGoals];
      
      PFQuery *query = [PFInstallation query];
      [query whereKey:@"user" equalTo:weakSelf.user];
      
      [PFPush sendPushMessageToQueryInBackground:query withMessage:[NSString stringWithFormat:@"%@ did edit goal %@",[PFUser currentUser][@"fullName"],weakSelf.selectedCell.goal[@"caption"]]];
    }
  }];
}

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(notificationGoalModified:)
                                               name:kNotificationNameGoalEdited
                                             object:nil];
  
  [self.tableView registerClass:[CEIGoalTableViewCell class]
         forCellReuseIdentifier:kIdentifierCellMission];
  
  __weak typeof (self) weakSelf = self;
  
  UIColor *colorTop = [UIColor colorWithWhite:1.0 alpha:0.1];
  UIColor *colorBottom = [UIColor colorWithWhite:0.0 alpha:0.7];
  NSArray *colors =  [NSArray arrayWithObjects:(id)colorTop.CGColor, colorBottom.CGColor, nil];
  
  NSNumber *stopTop = [NSNumber numberWithFloat:-0.4];
  NSNumber *stopBottom = [NSNumber numberWithFloat:0.8];
  NSArray *locations = [NSArray arrayWithObjects:stopTop, stopBottom, nil];
  
  CAGradientLayer *headerLayer = [CAGradientLayer layer];
  headerLayer.colors = colors;
  headerLayer.locations = locations;
  
  headerLayer.frame = self.imageViewBackgroud.bounds;

  [self.imageViewBackgroud.layer insertSublayer:headerLayer atIndex:0];
  
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
        weakSelf.imageViewProfile.layer.borderWidth = 1.0f;
        weakSelf.imageViewProfile.layer.borderColor = [[UIColor whiteColor]CGColor];
        
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
  self.labelMissionDuration.alpha = 0.8f;
    
  self.labelMissionName.textColor = [UIColor whiteColor];
  self.labelUserName.textColor = [UIColor whiteColor ];

  self.tableView.backgroundColor = [UIColor whiteColor];
  
#warning TODO: a bit hacky way, but nowthing else seems to work...
  if (self.isMentor) {
  
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabelTableViewHeader:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
  }
}

- (void)refresh{
  
  [self fetchGoals];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  [self refresh];
  
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
    
    PFUser *user = self.isMentor ? self.user : [PFUser currentUser];
    
    [queryGoals whereKey:@"user" equalTo:user];
    [queryGoals whereKey:@"mission" equalTo:self.mission];
    [queryGoals findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayGoals = [NSMutableArray arrayWithArray:[objects sortedArrayUsingComparator:^NSComparisonResult(PFObject *goal1, PFObject *goal2) {
          
          NSNumber *number1 = goal1[@"orderIndex"];
          NSNumber *number2 = goal2[@"orderIndex"];
          
          return [number1 compare:number2];
        }]];
        
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

            weakSelf.arrayGoalSteps = [NSMutableArray arrayWithArray:objects];
            
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
    
    addEncouragementViewController.arrayFollowersAvailable = [NSMutableArray arrayWithObjects:self.user, nil];
  }
  else
    if ([segue.identifier isEqualToString:kIdentifierSegueMissionToAddGoal]) {
      
      ((CEIAddGoalViewController *)segue.destinationViewController).goalAdded = self.goalSelected;
      ((CEIAddGoalViewController *)segue.destinationViewController).editing = YES;
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
  
  if (vc.encouragementInPlace == NO){
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put an Encouragement"];
    return NO;
  }
  
  if (vc.arrayFollowersSelected.count == 0){
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Select at least one Follower to Encourage"];
    return NO;
  }
  
  [vc.arrayFollowersSelected enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop){

    PFObject *encouragement = [PFObject objectWithClassName:@"Encouragement"];
    
    encouragement[@"caption"] = vc.textView.text;
    encouragement[@"mentorID"] = [PFUser currentUser];
    encouragement[@"followerID"] = user;
    
    [encouragement saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else {
        
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"user" equalTo:user];
        
        [PFPush sendPushMessageToQueryInBackground:query
                                       withMessage:[NSString stringWithFormat:@"%@: %@",[PFUser currentUser][@"fullName"],vc.textView.text]];
      }
    }];
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
  
  NSArray *arraySorted = [NSMutableArray arrayWithArray:[self.arrayGoals sortedArrayUsingComparator:^NSComparisonResult(PFObject *goal1, PFObject *goal2) {
    
    NSNumber *number1 = goal1[@"orderIndex"];
    NSNumber *number2 = goal2[@"orderIndex"];
    
    return [number1 compare:number2];
  }]];
  
  PFObject *goal = [arraySorted objectAtIndex:indexPath.section];
  
  [cell configureWithGoal:goal
                  mission:self.mission
           arrayGoalSteps:[self arrayGoalStepsForGoal:goal]];
  
  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  PFObject *goal = [self.arrayGoals objectAtIndex:section];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             tableView.frame.size.width,
                                                             kHeightHeader)];
  label.textAlignment = NSTextAlignmentLeft;
  label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
  label.text = [NSString stringWithFormat:@"  %@",goal[@"caption"]];
  label.textColor = [UIColor whiteColor];
  label.alpha = 0.7f;
  label.backgroundColor = [UIColor colorWithRed:0.412 green:0.427 blue:0.592 alpha:1];
  label.tag = kTagOffsetLabelTableViewHeader + section;
  
  return label;
}

- (void)tapLabelTableViewHeader:(id)paramSender{
  
  if ([paramSender isKindOfClass:[UITapGestureRecognizer class]]) {
    
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)paramSender;
    
    UIView *view = tapGestureRecognizer.view;
      
    
    CGPoint tapPoint = [tapGestureRecognizer locationInView:view];
    
    __block UIView *viewSelected = nil;
    
    [view.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
      
      if (CGRectContainsPoint(view.frame, tapPoint) && view.tag >= kTagOffsetLabelTableViewHeader) {
        
        viewSelected = view;
        *stop = YES;
      }
    }];
    
    if (viewSelected == nil) {
      
      return;
    }
    
    NSInteger tag = viewSelected.tag;
    
    self.goalSelected = [self.arrayGoals objectAtIndex:(tag - kTagOffsetLabelTableViewHeader)];
    [self performSegueWithIdentifier:kIdentifierSegueMissionToAddGoal sender:self];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
  
  return kHeightFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  
  return kHeightHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
  
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                          0.0f,
                                                          tableView.frame.size.width,
                                                          kHeightFooter)];
  
  PFObject *goal = [self.arrayGoals objectAtIndex:section];
  
  NSArray *arrayGoalSteps = [self arrayGoalStepsForGoal:goal withDone:YES];
  
#warning TODO: localizations
  UILabel *labelLeft = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 -8,
                                                                 tableView.frame.size.width * 0.6f,
                                                                 kHeightFooter)];
  
  
  labelLeft.textAlignment = NSTextAlignmentLeft;
  labelLeft.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
  labelLeft.text = [NSString stringWithFormat:@"  Must be completed %@ daily",goal[@"time"]];
  labelLeft.textColor = [UIColor colorWithRed:0.412 green:0.427 blue:0.592 alpha:1];
  [view addSubview:labelLeft];
  
  UILabel *labelRight = [[UILabel alloc] initWithFrame:CGRectMake((tableView.frame.size.width * 0.6f)-10,
                                                             -8,
                                                             tableView.frame.size.width * 0.4f,
                                                             kHeightFooter)];
  labelRight.textAlignment = NSTextAlignmentRight;
  labelRight.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
  
    
  __block NSInteger goalsChecked = 0;
  [self.arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStep, NSUInteger idx, BOOL *stop) {
    
    if ([goalStep[@"done"] boolValue]) {
      
      goalsChecked++;
    }
  }];
  
  NSInteger totalGoalsToCheck = [NSDate totalDaysCountForMission:self.mission];
  
  if (![goal[@"isRecurring"] boolValue]) {
    
    NSArray *arrayDays = goal[@"days"];
    
    totalGoalsToCheck *= ((CGFloat)arrayDays.count) / 7.0f;
  }
  
  labelRight.text = [NSString stringWithFormat:@"%.0f %% of goal",fabs((goalsChecked * 100.0f / ((CGFloat)totalGoalsToCheck)))];
  labelRight.textColor = [UIColor colorWithRed:0.412 green:0.427 blue:0.592 alpha:1];
  [view addSubview:labelRight];
  
  return view;
}

#pragma mark - Convinience Methods

- (NSMutableArray *)arrayGoalStepsForGoal:(PFObject *)paramGoal{
  
  NSMutableArray *arrayGoalsFiltered = [[NSMutableArray alloc] init];
  
  NSString *goalID = paramGoal.objectId;
  
  [self.arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStep, NSUInteger idx, BOOL *stop) {
    
    NSString *goalIDTest = [goalStep[@"goal"] objectId];
    
    if ([goalID isEqualToString:goalIDTest]){
    
      [arrayGoalsFiltered addObject:goalStep];
    }
  }];
  
  return arrayGoalsFiltered;
}

- (NSMutableArray *)arrayGoalStepsForGoal:(PFObject *)paramGoal withDone:(BOOL)paramDone{
  
  NSMutableArray *arrayGoalsFiltered = [[NSMutableArray alloc] init];
  
  NSString *goalID = paramGoal.objectId;
  
  [self.arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStep, NSUInteger idx, BOOL *stop) {
    
    NSString *goalIDTest = [goalStep[@"goal"] objectId];
    
    BOOL done = [goalStep[@"done"] boolValue];
    
    if ([goalID isEqualToString:goalIDTest] && done){
      
      [arrayGoalsFiltered addObject:goalStep];
    }
  }];
  
  return arrayGoalsFiltered;
}

#pragma mark - CEIGoalTableViewCell Delegate

- (void)goalTableViewCell:(CEIGoalTableViewCell *)paramGoalTableViewCell didTapDailyChoresView:(CEIDailyChoresView *)paramDailyChoresView{
  
  self.selectedCell = paramGoalTableViewCell;
  self.selectedDailyChoresView = paramDailyChoresView;
  
  UIView *contentView = nil;
  KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                             KLCPopupVerticalLayoutCenter);
  
  
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
      
      if (goalStep[@"done"] != nil) {
        
        goalStepViewCheckup.textView.text = goalStep[@"caption"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
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
      else{
        
#warning TODO: localization
        goalStepViewCheckup.textView.text = @"This has not been checked in yet!";
        goalStepViewCheckup.labelDay.text = goalStep[@"day"];
        goalStepViewCheckup.labelDone.text = @"-";
      }
    }
    
    contentView = goalStepViewCheckup;
    
      }
  else{
    
    CEIGoalStepViewCheckin *goalStepViewCheckin = [[[NSBundle mainBundle] loadNibNamed:kNibNameCEIGoalStepViewCheckin
                                                                                owner:self
                                                                              options:nil]
                                                   lastObject];
    goalStepViewCheckin.delegate = self;
    
    if (IS_IPHONE_5) {
      
      goalStepViewCheckin.frame = CGRectMake(goalStepViewCheckin.frame.origin.x,
                                             goalStepViewCheckin.frame.origin.y,
                                             goalStepViewCheckin.frame.size.width,
                                             goalStepViewCheckin.frame.size.height + 88.0f);
    }
    
    PFObject *goal = paramGoalTableViewCell.goal;
    
    goalStepViewCheckin.labelGoalTitle.text = goal[@"caption"];
    
    if (self.selectedDailyChoresView.goalStep[@"done"] != nil) {
  
      layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                  KLCPopupVerticalLayoutCenter);
      
      goalStepViewCheckin.textView.text = self.selectedDailyChoresView.goalStep[@"caption"];
      goalStepViewCheckin.labelGoalCharactersRemaining.text = @"Already checked in!";
      
      goalStepViewCheckin.textView.editable = NO;
      goalStepViewCheckin.buttonNo.enabled = NO;
      goalStepViewCheckin.buttonYes.enabled = NO;
      
      
      if ([self.selectedDailyChoresView.goalStep[@"done"] boolValue]) {

        [goalStepViewCheckin tapButtonYes:nil];
      }
      else{
        
        [goalStepViewCheckin tapButtonNo:nil];
      }
    }
    else{
      
      layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                  KLCPopupVerticalLayoutTop);
    }
    
    contentView = goalStepViewCheckin;
  }
  
  KLCPopup *popup = [KLCPopup popupWithContentView:contentView
                                          showType:KLCPopupShowTypeBounceInFromTop
                                       dismissType:KLCPopupDismissTypeSlideOutToBottom
                                          maskType:KLCPopupMaskTypeDimmed
                          dismissOnBackgroundTouch:NO
                             dismissOnContentTouch:NO];
  
  [popup showWithLayout:layout];
  
  if ([contentView isKindOfClass:[CEIGoalStepViewCheckin class]]) {
    
    CEIGoalStepViewCheckin *view = (CEIGoalStepViewCheckin *)contentView;
    [view.textView becomeFirstResponder];
  }
}

#pragma mark - CEIGoalStepViewCheckup Delegate

- (void)goalStepViewCheckupDidTapDone:(CEIGoalStepViewCheckup *)paramGoalStepViewCheckup{
  
  [KLCPopup dismissAllPopups];
}

- (void)goalStepViewCheckupDidTapEncourage:(CEIGoalStepViewCheckup *)paramGoalStepViewCheckup{
  
  [KLCPopup dismissAllPopups];
  [self performSegueWithIdentifier:kIdentifierSegueMissionAddEncouragement sender:self];
}

#pragma mark - CEIGoalStepViewCheckin Delegate

- (void)goalStepViewCheckinDidTapDone:(CEIGoalStepViewCheckin *)paramGoalStepViewCheckin{
  
  if (paramGoalStepViewCheckin.textView.editable) {
    
    if (!paramGoalStepViewCheckin.isDoneSelected){
    
      [CEIAlertView showAlertViewWithValidationMessage:@"Please confirim wether you have fulfilled the goal or not."];
      return;
    }
    
    __weak typeof (self) weakSelf = self;
    
    PFObject *goalStep = self.selectedDailyChoresView.goalStep;
    
    goalStep[@"caption"] = paramGoalStepViewCheckin.textView.text;
    goalStep[@"done"] = [NSNumber numberWithBool:paramGoalStepViewCheckin.done];
    goalStep[@"goal"] = self.goalSelected;
    
    [self.arrayGoalSteps addObject:goalStep];
    [self.selectedDailyChoresView configureWithGoalStep:goalStep];
    
    [goalStep saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{

        [weakSelf.selectedDailyChoresView updateWithDone:paramGoalStepViewCheckin.done
                                             comment:paramGoalStepViewCheckin.textView.text];
        
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"user" equalTo:weakSelf.user];
        
        [PFPush sendPushMessageToQueryInBackground:query withMessage:[NSString stringWithFormat:@"%@: %@ %@",[PFUser currentUser][@"fullName"],paramGoalStepViewCheckin.done ? @"Done:" : @"Didn't do it:",weakSelf.selectedCell.goal[@"caption"]]];
      }
    }];
  }
  
  [self.tableView reloadData];
  
  [KLCPopup dismissAllPopups];
}

- (void)goalStepViewCheckinDidTapCancel:(CEIGoalStepViewCheckin *)paramGoalStepViewCheckin{

  [KLCPopup dismissAllPopups];
}

@end
