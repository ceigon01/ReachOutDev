//
//  CEIAllMissionsViewController.m
//  ReachOut
//
//  Created by Jason Smith on 23.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAllMissionsViewController.h"
#import "CEIAlertView.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "CEIDoubleDisclosureCell.h"
#import <Parse/Parse.h>
#import "CEIAddMissionViewController.h"
#import "NSDate+Difference.h"
#import "CEIDay.h"
#import "MBProgressHUD.h"
#import "CEIAddGoalViewController.h"
#import "CEINotificationNames.h"

static NSString *const kIdentifierCellAllMissionsToAddMission = @"kIdentifierCellAllMissionsToAddMission";

@interface CEIAllMissionsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *arrayMissions;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;

@end

@implementation CEIAllMissionsViewController

- (void)dealloc{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationAddMission:(NSNotification *)paramNotification{
  
  MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressHUD.labelText = @"Updating mission...";
  
  NSDictionary *dictionary = paramNotification.object;
  
  PFObject *mission = [dictionary objectForKey:@"mission"];
  NSArray *arrayGoals = [dictionary objectForKey:@"goals"];
  NSArray *arrayFlock = [dictionary objectForKey:@"flock"];
  
  PFFile *fileImage = mission[@"image"];
  if (fileImage == nil) {

    UIImage *image = [UIImage imageNamed:@"cathedral"];
    PFFile *defaultCover = [PFFile fileWithData:UIImageJPEGRepresentation(image, 0.6f)];
    mission[@"image"] = defaultCover;
//    [CEIAlertView showAlertViewWithValidationMessage:@"Please use a background image."];
//    return;
  }
  
  NSString *caption = mission[@"caption"];
  if (caption.length < 1) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put a caption."];
    return;
  }
  
  BOOL isNeverending = [mission[@"isNeverending"] boolValue];
  NSString *timeCount = mission[@"timeCount"];
  if (!isNeverending && timeCount.length < 1) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please set length of your mission, or select \'Never ending mission\'."];
    return;
  }
  
  if (arrayFlock.count == 0) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please select followers, that you want on this mission."];
    return;
  }
  
  if (arrayGoals.count == 0) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please set some goals."];
    return;
  }
  else{
    
    [arrayGoals enumerateObjectsUsingBlock:^(PFObject *goal, NSUInteger idx, BOOL *stop) {
      if (![goal[@"stepsGenerated"] boolValue]) {
        
        NSMutableArray *arrayGoalSteps = [[NSMutableArray alloc] init];
        
#warning TODO: neverending set to 3 years...
        NSUInteger totalDays = 0;
        
        if (isNeverending) {
          
          totalDays = 1000;  //around three years, also it's the Parse fetch cap
        }
        else{
          
          totalDays = [NSDate totalDaysCountForMission:mission];
          
          NSCalendar *calendar = [NSCalendar currentCalendar];
          
#warning TODO: dunno why +1...
          PFRelation *relation = [goal relationForKey:@"goalSteps"];
          for (NSUInteger daysCount = 1; daysCount < totalDays + 1; daysCount++) {
            
            PFObject *goalStep = [PFObject objectWithClassName:@"GoalStep"];
            goalStep[@"goal"] = goal;
            goalStep[@"mission"] = mission;
            
            NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit
                                                           fromDate:[NSDate date]];
            
            dateComponents.day += daysCount;
#warning TODO: dunno why -2...
            dateComponents.weekday = (dateComponents.weekday + daysCount - 2)%7;
            
            goalStep[@"date"] = [calendar dateFromComponents:dateComponents];
            
            goalStep[@"day"] = [CEIDay dayNameWithDayNumber:(dateComponents.weekday)];
            
            if ([goal[@"isRecurring"] boolValue]) {
              
              goalStep[@"available"] = @YES;
            }
            else{
              
              NSArray *arrayDays = goal[@"days"];
              
              if ([arrayDays indexOfObject:goalStep[@"day"]] == NSNotFound) {
                
                goalStep[@"available"] = @NO;
              }
              else{
                
                goalStep[@"available"] = @YES;
              }
            }
            
            [arrayGoalSteps addObject:goalStep];
          }
          
          [PFObject saveAll:arrayGoalSteps];
          [arrayGoalSteps enumerateObjectsUsingBlock:^(PFObject *goalStep, NSUInteger idx, BOOL *stop) {
            
            [relation addObject:goalStep];
          }];
          [arrayGoalSteps removeAllObjects];
        }
        
        goal[@"stepsGenerated"] = @YES;
        [goal save];
      }
    }];
  }
  
  __weak typeof (self) weakSelf = self;
  
  mission[@"dateBegins"] = [NSDate date];
  mission[@"userReporter"] = [PFUser currentUser];
  mission[@"asigneesCount"] = [NSNumber numberWithInteger:arrayFlock.count];
  [mission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    [progressHUD hide:YES];
    
    BOOL isEditing = [weakSelf.arrayMissions indexOfObject:mission] != NSNotFound;
    
    if (!isEditing) {
      
      [weakSelf.arrayMissions addObject:mission];
      [weakSelf.tableView reloadData];
    }
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else{
      
      [arrayFlock enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
        
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"user" equalTo:user];
        
        NSString *pushText = [NSString stringWithFormat:@"%@ has %@ mission: %@",[PFUser currentUser][@"fullName"],(isEditing ? @"edited a" : @"assigned you a new"), mission[@"caption"]];
        
        [PFPush sendPushMessageToQueryInBackground:query
                                       withMessage:pushText];
      }];
    }
  }];
  
}

- (void)viewDidLoad{
  [super viewDidLoad];

  self.indexPathSelected = nil;
  
  [self fetchMissions];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(notificationAddMission:)
                                               name:kNotificationNameMissionAdded
                                             object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  __weak typeof(self) weakSelf = self;
  [self.tableView addPullToRefreshActionHandler:^{
    
    [weakSelf fetchMissions];
  }
                          ProgressImagesGifName:@"run@2x.gif"
                           LoadingImagesGifName:@"run@2x.gif"
                        ProgressScrollThreshold:60
                          LoadingImageFrameRate:30];
}

- (void)fetchMissions{
  
  PFQuery *query = [PFQuery queryWithClassName:@"Mission"];
    
  [query whereKey:@"userReporter" equalTo:[PFUser currentUser]];
  
  __weak CEIAllMissionsViewController *weakSelf = self;
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [weakSelf.tableView stopRefreshAnimation];
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else {
      
      weakSelf.arrayMissions = [NSMutableArray arrayWithArray:objects];
      [weakSelf.tableView reloadData];
    }
  }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqual:kIdentifierCellAllMissionsToAddMission] && self.indexPathSelected != nil) {
   
    ((CEIAddMissionViewController *)segue.destinationViewController).mission = [self.arrayMissions objectAtIndex:self.indexPathSelected.row];
    self.indexPathSelected = nil;
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{
  
  if ([fromViewController isKindOfClass:[CEIAddGoalViewController class]]) {
    
    return NO;
  }
  
  if ([fromViewController isKindOfClass:[CEIAddMissionViewController class]]) {
    
  }
  
  return YES;
}


- (IBAction)unwindAddMission:(UIStoryboardSegue *)unwindSegue{
  
}

- (IBAction)unwindAddGoal:(UIStoryboardSegue *)unwindSegue{
  
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayMissions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIDoubleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellAllMissionsToAddMission
                                                                  forIndexPath:indexPath];
  
  PFObject *mission = [self.arrayMissions objectAtIndex:indexPath.row];
  
  cell.textLabel.text = mission[@"caption"];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",mission[@"asigneesCount"]];
  cell.labelLowerDetail.text = @"Followers";
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  self.indexPathSelected = indexPath;
  [self performSegueWithIdentifier:kIdentifierCellAllMissionsToAddMission
                            sender:self];
}

@end
