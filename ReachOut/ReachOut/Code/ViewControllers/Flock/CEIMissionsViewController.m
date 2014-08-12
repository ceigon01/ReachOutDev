//
//  CEIMissionsViewController.m
//  ReachOut
//
//  Created by Jason Smith on 11.06.2014.
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

@interface CEIMissionsViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>

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
  if (self.isMentor) {
    
    [query whereKey:@"userReporter" equalTo:[PFUser currentUser]];
    [query whereKey:@"usersAsignees" equalTo:self.user];
  }
  else{
    
    [query whereKey:@"userReporter" equalTo:self.user];
    [query whereKey:@"usersAsignees" equalTo:[PFUser currentUser]];
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
    ((CEIMissionViewController *)segue.destinationViewController).mentor = self.isMentor;
    ((CEIMissionViewController *)segue.destinationViewController).user = self.user;
  }
}

- (IBAction)unwindAddMission:(UIStoryboardSegue *)unwindSegue{
  
  if ([unwindSegue.sourceViewController isKindOfClass:[CEIAddMissionViewController class]]) {
    
    [self.tableView reloadData];
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{
  
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
  cell.delegate = self;
  
  NSArray *arrayCountAndSeason = [mission[@"timeCount"] componentsSeparatedByString:@" "];
  
  if (arrayCountAndSeason.count == 2){

    cell.detailTextLabel.text = [arrayCountAndSeason objectAtIndex:0];
    cell.labelLowerDetail.text = [arrayCountAndSeason objectAtIndex:1];
  }
  else if (arrayCountAndSeason.count == 1){
    
    cell.detailTextLabel.text = @"-";
    cell.labelLowerDetail.text = [arrayCountAndSeason objectAtIndex:0];
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  self.indexPathSelected = indexPath;
  [self performSegueWithIdentifier:kSegueIdentifierMissionsToMission sender:self];
}

@end
