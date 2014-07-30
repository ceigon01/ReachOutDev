//
//  CEIFlockViewController.m
//  ReachOut
//
//  Created by Jason Smith on 09.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIFlockViewController.h"
#import <Parse/Parse.h>
#import "CEIAlertView.h"
#import "UIImageView+WebCache.h"
#import "CEIDoubleDisclosureCell.h"
#import "CEIMissionsViewController.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "CEIAddUserViewController.h"
#import "CEINotificationNames.h"
#import "CEIUserTableViewCell.h"

static NSString *const kCellIdentifierFollower = @"kCellIdentifierFollower";
static NSString *const kSegueIdentifierFlockToMissions = @"kSegueIdentifier_Flock_Missions";
static NSString *const kIdentifierSegueMentorsToAddUser = @"kIdentifierSegueFlockToAddUser";

@interface CEIFlockViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;
@property (nonatomic, strong) NSMutableArray *arrayFlock;

- (void)fetchFlock;

@end

@implementation CEIFlockViewController

- (void)dealloc{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleNotificationFollowerAdded:)
                                               name:kNotificationNameUserFollowerAdded
                                             object:nil];
  
#warning TODO: localization
  self.title = @"Flock";
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CEIUserTableViewCell"
                                            bundle:[NSBundle mainBundle]]
       forCellReuseIdentifier:kCellIdentifierFollower];
  
  [self fetchFlock];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
    __weak typeof(self) weakSelf =self;
    [self.tableView addPullToRefreshActionHandler:^{
      
      [weakSelf fetchFlock];
    }
                            ProgressImagesGifName:@"run@2x.gif"
                             LoadingImagesGifName:@"run@2x.gif"
                          ProgressScrollThreshold:60
                            LoadingImageFrameRate:30];
}

- (void)fetchFlock{
  
  __weak CEIFlockViewController *weakSelf = self;
  
  PFQuery *query = [PFUser query];
  if (query && [PFUser currentUser]) {
   
//    [query whereKey:@"mentors" equalTo:[PFUser currentUser]];
    
    query = [[[PFUser currentUser] relationForKey:@"followers"] query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      [weakSelf.tableView stopRefreshAnimation];
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayFlock = [NSMutableArray arrayWithArray:objects];
        [weakSelf.tableView reloadData];
      }
    }];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kSegueIdentifierFlockToMissions]) {
    
    ((CEIMissionsViewController *)segue.destinationViewController).user = [self.arrayFlock objectAtIndex:self.indexPathSelected.row];
    ((CEIMissionsViewController *)segue.destinationViewController).isMentor = YES;
  }
  else
    if ([segue.identifier isEqualToString:kIdentifierSegueMentorsToAddUser]) {
      
      ((CEIAddUserViewController *)segue.destinationViewController).isMentor = NO;
    }
}

#pragma mark - UITableView Datasource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  return kHeightUserCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayFlock.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierFollower
                                                               forIndexPath:indexPath];
  
  PFUser *user = [self.arrayFlock objectAtIndex:indexPath.row];
  
  [cell configureWithUser:user];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  self.indexPathSelected = indexPath;
  [self performSegueWithIdentifier:kSegueIdentifierFlockToMissions
                            sender:self];
}

#pragma mark - Notification Handling

- (void)handleNotificationFollowerAdded:(NSNotification *)paramNotification{
  
  [self.arrayFlock addObject:paramNotification.object];
  [self.tableView reloadData];
}

@end
