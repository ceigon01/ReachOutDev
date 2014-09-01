//
//  CEIGoalNotificationsPreviewViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 23.08.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIGoalNotificationsPreviewViewController.h"
#import <Parse/Parse.h>
#import "CEIAlertView.h"
#import "CEIColor.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "CEIGoalNotificationSetupViewController.h"
#import "MBProgressHUD.h"

static NSString *const kCellIdentifierGoalNotificationPreview = @"kCellIdentifierGoalNotificationPreview";

static NSString *const kIdentifierSegueNotificationsPreviewToNotificationSetup = @"kIdentifierSegueNotificationsPreviewToNotificationSetup";

@interface CEIGoalNotificationsPreviewViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *arrayMissions;
@property (nonatomic, strong) NSMutableDictionary *dictionaryGoals;
@property (nonatomic, strong) NSMutableDictionary *dictionaryNotifications;

@property (nonatomic, strong) PFObject *selectedGoal;
@property (nonatomic, strong) PFObject *selectedMission;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation CEIGoalNotificationsPreviewViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localizations
  self.title = @"Goal Notifications";
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  [self fetchGoals];
  [self fetchNotifications];
  
  __weak typeof(self) weakSelf = self;
  [self.tableView addPullToRefreshActionHandler:^{
    
    [weakSelf fetchGoals];
  }
                          ProgressImagesGifName:@"run@2x.gif"
                           LoadingImagesGifName:@"run@2x.gif"
                        ProgressScrollThreshold:60
                          LoadingImageFrameRate:30];
}

- (void)fetchNotifications{
  
  [self.dictionaryGoals removeAllObjects];
  
  __weak typeof (self) weakSelf = self;
  
  [[[UIApplication sharedApplication] scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *localNotification, NSUInteger idx, BOOL *stop) {
    
    NSString *goalID = [localNotification.userInfo objectForKey:kKeyGoalLocalNotification];
    if (goalID) {
     
      [weakSelf.dictionaryNotifications setObject:localNotification forKey:goalID];
    }
  }];
}

- (void)fetchGoals{
  
  PFQuery *query = [PFQuery queryWithClassName:@"Mission"];
  
  [query whereKey:@"usersAsignees" equalTo:[PFUser currentUser]];
  
  __weak typeof (self) weakSelf = self;
  
  [self.dictionaryGoals removeAllObjects];
  [self.arrayMissions removeAllObjects];
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [weakSelf.tableView stopRefreshAnimation];
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else {
      
      weakSelf.arrayMissions = [NSMutableArray arrayWithArray:objects];
      [weakSelf.arrayMissions enumerateObjectsUsingBlock:^(PFObject *mission, NSUInteger idx, BOOL *stop) {

        PFQuery *query = [[mission relationForKey:@"goals"] query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          
          [objects enumerateObjectsUsingBlock:^(PFObject *goal, NSUInteger idx, BOOL *stop) {
            
            if (![self.dictionaryGoals objectForKey:mission.objectId]) {
              
              [self.dictionaryGoals setObject:[NSMutableArray array] forKey:mission.objectId];
            }
            
            NSMutableArray *arrayGoals = [self.dictionaryGoals objectForKey:mission.objectId];
            [arrayGoals addObject:goal];
          }];
          
          [weakSelf.tableView reloadData];
        }];
      }];

      [weakSelf.tableView reloadData];
    }
  }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueNotificationsPreviewToNotificationSetup]) {
    
    ((CEIGoalNotificationSetupViewController *)segue.destinationViewController).goal = self.selectedGoal;
    ((CEIGoalNotificationSetupViewController *)segue.destinationViewController).mission = self.selectedMission;
    
    self.selectedMission = nil;
    self.selectedGoal = nil;
  }
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return [self.dictionaryGoals allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  PFObject *mission = [self.arrayMissions objectAtIndex:section];
  
  NSArray *arrayGoals = [self.dictionaryGoals objectForKey:mission.objectId];
  
  return arrayGoals.count;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[CEIColor colorIdle]];
    PFObject *mission = [self.arrayMissions objectAtIndex:section];
    UILabel *missionText = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width, 30)];
    missionText.textColor = [UIColor whiteColor];
    missionText.text = mission[@"caption"];
    missionText.numberOfLines = 0;
    [missionText sizeToFit];
    
    [headerView addSubview:missionText];
    
    return headerView;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
  
  PFObject *mission = [self.arrayMissions objectAtIndex:section];
  
  return mission[@"caption"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierGoalNotificationPreview
                                                          forIndexPath:indexPath];
  
  PFObject *mission = [self.arrayMissions objectAtIndex:indexPath.section];
  
  NSArray *arrayGoals = [self.dictionaryGoals objectForKey:mission.objectId];
  
  PFObject *goal = [arrayGoals objectAtIndex:indexPath.row];
  
[cell.imageView setImage:[UIImage imageNamed:@"noticeIcon"]];
  cell.textLabel.text = goal[@"caption"];
  
  UILocalNotification *notification = [self.dictionaryNotifications objectForKey:goal.objectId];
  
#warning TODO: localizations
  if (notification.fireDate != nil) {
    
    cell.detailTextLabel.text = [notification.userInfo objectForKey:kKeyGoalLocalNotificationDescription];
  }
  else{
    
    cell.detailTextLabel.text = @"no notification set";
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  self.selectedMission = [self.arrayMissions objectAtIndex:indexPath.section];
  
  NSArray *arrayGoals = [self.dictionaryGoals objectForKey:self.selectedMission.objectId];
  self.selectedGoal = [arrayGoals objectAtIndex:indexPath.row];
  
  [self performSegueWithIdentifier:kIdentifierSegueNotificationsPreviewToNotificationSetup sender:self];
}

#pragma mark - Action Handling

- (IBAction)tapButtonResetNotifications:(id)paramSender{
  
#warning TODO: localizations
  MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressHUD.labelText = @"Removing notifications...";
  
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  
  [progressHUD performSelector:@selector(hide:) withObject:nil afterDelay:1.0f];
  
  [self.dictionaryNotifications removeAllObjects];
  [self.tableView reloadData];
}

#pragma mark - Lazy Getters

- (NSMutableDictionary *)dictionaryGoals{
  
  if (_dictionaryGoals == nil) {
    
    _dictionaryGoals = [[NSMutableDictionary alloc] init];
  }
  
  return _dictionaryGoals;
}

- (NSMutableDictionary *)dictionaryNotifications{
  
  if (_dictionaryNotifications == nil) {
    
    _dictionaryNotifications = [[NSMutableDictionary alloc] init];
  }
  
  return _dictionaryNotifications;
}

@end
