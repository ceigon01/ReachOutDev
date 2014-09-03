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
#import "PFQuery+FollowersAndMentors.h"

static NSString *const kCellIdentifierFollower = @"kCellIdentifierFollower";
static NSString *const kSegueIdentifierFlockToMissions = @"kSegueIdentifier_Flock_Missions";
static NSString *const kIdentifierSegueMentorsToAddUser = @"kIdentifierSegueFlockToAddUser";

@interface CEIFlockViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>

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
  self.title = @"My Flock";
  [self.tableView registerNib:[UINib nibWithNibName:@"CEIUserTableViewCell"
                                            bundle:[NSBundle mainBundle]]
       forCellReuseIdentifier:kCellIdentifierFollower];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  [self fetchFlock];
  
  __weak typeof(self) weakSelf = self;
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
  
  if ([PFUser currentUser]) {
    
    PFQuery *query = [PFQuery followers];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      [weakSelf.tableView stopRefreshAnimation];
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayFlock = [NSMutableArray arrayWithArray:objects];
        [weakSelf.tableView reloadData];
          
          if(weakSelf.arrayFlock.count ==0){
              UIView *background = [[UIView alloc] initWithFrame:self.tableView.bounds];
              background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"flockBack"]];
              self.tableView.backgroundView = background;
          }else{
              UIView *background = [[UIView alloc] initWithFrame:self.tableView.bounds];
              background.backgroundColor = [UIColor whiteColor];
              self.tableView.backgroundView = background;
          }
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
  
  cell.delegate = self;
  
#warning TODO: localizations
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.backgroundColor = [UIColor redColor];
  [button setTitle:@"Delete" forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  button.tag = indexPath.row;
  
  [cell setRightUtilityButtons:@[
                                 button,
                                 ]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  self.indexPathSelected = indexPath;
  [self performSegueWithIdentifier:kSegueIdentifierFlockToMissions
                            sender:self];
}


#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
  
  NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
  
  PFUser *user = [self.arrayFlock objectAtIndex:cellIndexPath.row];
  
  [self.arrayFlock removeObjectAtIndex:cellIndexPath.row];
  [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
  
  [PFCloud callFunctionInBackground:@"removeMentorFollowerRelation" withParameters:@{
                                                                                     @"mentor" : [PFUser currentUser].objectId,
                                                                                     @"follower" : user.objectId
                                                                                     }
                              block:^(NSDictionary *results, NSError *error) {
                                
                                if (error) {
                                  
                                  [CEIAlertView showAlertViewWithError:error];
                                }
                                else{
                                  
                                  NSLog(@"%@",results);
                                }
                              }];
}

#pragma mark - Notification Handling

- (void)handleNotificationFollowerAdded:(NSNotification *)paramNotification{
  
  [self.arrayFlock addObject:paramNotification.object];
  [self.tableView reloadData];
}

@end
