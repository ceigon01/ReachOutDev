//
//  CEIMissionsViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMissionsViewController.h"
#import "CEIUserPortraitView.h"
#import "CEIDoubleDisclosureCell.h"
#import <Parse/Parse.h>
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Difference.h"
#import "CEIMissionViewController.h"
#import "CEIAddMissionViewController.h"
#import "CEIAlertView.h"

static NSString *const kSegueIdentifierMissionsToMission = @"kSegueIdentifier_Missions_Mission";
static NSString *const kCellIdentifierMissions = @"kCellIdentifierMissions";

@interface CEIMissionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayMissions;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;

- (void)fetchMissions;

@end

@implementation CEIMissionsViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localization
  self.title = @"Missions";
  
  if ([[PFUser currentUser][@"isMentor"] isEqual:@0]) {
    
    self.navigationItem.rightBarButtonItem = nil;
  }

  [self fetchMissions];
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
  if ([[PFUser currentUser][@"isMentor"] isEqual:@1]) {
    
    [query whereKey:@"userIDReporter" equalTo:self.user.objectId];
    [query whereKey:@"userIDAsignee" equalTo:[PFUser currentUser].objectId];
  }
  else{
    
    [query whereKey:@"userIDAsignee" equalTo:self.user.objectId];
    [query whereKey:@"userIDReporter" equalTo:[PFUser currentUser].objectId];
  }
  
  __weak CEIMissionsViewController *weakSelf = self;
  
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
  
  if ([segue.identifier isEqualToString:kSegueIdentifierMissionsToMission]) {
    
    ((CEIMissionViewController *)segue.destinationViewController).mission = [self.arrayMissions objectAtIndex:self.indexPathSelected.row];
    ((CEIMissionViewController *)segue.destinationViewController).mentor = self.mentor;
  }
}

- (IBAction)unwindAddMission:(UIStoryboardSegue *)unwindSegue{
  
  if ([unwindSegue.sourceViewController isKindOfClass:[CEIAddMissionViewController class]]) {
    
    [self.tableView reloadData];
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{
//  
//#warning TODO: localizations
//  CEIAddMissionViewController *vc = nil;
//  
//  if ([fromViewController isKindOfClass:[CEIAddMissionViewController class]]) {
//    
//    vc = (CEIAddMissionViewController *)fromViewController;
//  }
//  else {
//    
//    [CEIAlertView showAlertViewWithValidationMessage:@"Shouldn't get here!"];
//    return NO;
//  }
//  
//  if (vc.mission){
//  
//    if (vc.mission[@"caption"] == nil) {
//      
//      [CEIAlertView showAlertViewWithValidationMessage:@"Please put a Caption"];
//      return NO;
//    }
//    
//    if (vc.arrayGoals.count == 0) {
//      
//      [CEIAlertView showAlertViewWithValidationMessage:@"You should add some goals to this mission!"];
//      return NO;
//    }
//    
//    __weak CEIMissionsViewController *weakSelf = self;
//    
//    PFObject *mission = vc.mission;
//    mission[@"userIDAsignee"] = self.user.objectId;
//    mission[@"userIDReporter"] = [PFUser currentUser].objectId;
//    
//    PFRelation *relation = [mission relationForKey:@"goals"];
//    [vc.arrayGoals enumerateObjectsUsingBlock:^(PFObject *goal, NSUInteger idx, BOOL *stop) {
//  
//      [relation addObject:goal];
//    }];
//    
//    [mission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//      
//      if (error) {
//        
//        [CEIAlertView showAlertViewWithError:error];
//      }
//      else {
//        
//        [weakSelf.arrayMissions addObject:mission];
//        [weakSelf.tableView reloadData];
//      }
//    }];
//    
//  }
//  else {
//    
//    return NO;
//  }
  
  return YES;
}

#pragma mark - UITableVIew Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayMissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIDoubleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierMissions
                                                                  forIndexPath:indexPath];
  
  PFObject *mission = [self.arrayMissions objectAtIndex:indexPath.row];
  
  cell.textLabel.text = mission[@"caption"];
  
  NSDate *dateBegins = mission[@"dateBegins"];
  NSDate *dateEnds = mission[@"dateEnds"];
  NSInteger daysDifference = [dateBegins daysBetweenDate:dateEnds];
  
#warning TODO: implement
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)daysDifference];
  cell.labelLowerDetail.text = @"Days";
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  self.indexPathSelected = indexPath;
}

@end
