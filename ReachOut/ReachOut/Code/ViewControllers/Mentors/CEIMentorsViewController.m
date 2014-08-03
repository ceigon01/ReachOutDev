//
//  CEIMentorsViewController.m
//  ReachOut
//
//  Created by Jason Smith on 09.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMentorsViewController.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import "CEIMissionsViewController.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import <QuartzCore/QuartzCore.h>
#import "CEIAlertView.h"
#import "CEIAddUserViewController.h"
#import "CEINotificationNames.h"
#import "CEIUserTableViewCell.h"
#import "PFQuery+FollowersAndMentors.h"

static NSString *const kCellIdentifierMentor = @"kCellIdentifierMentor";
static NSString *const kSegueIdentifierMentorsToMissions = @"kSegueIdentifier_Mentors_Missions";
static NSString *const kIdentifierSegueMentorsToAddUser = @"kIdentifierSegueMentorsToAddUser";

@interface CEIMentorsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayMentors;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;

- (void)fetchMentors;

@end

@implementation CEIMentorsViewController

- (void)dealloc{

  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleNotificationMentorAdded:)
                                               name:kNotificationNameUserMentorAdded
                                             object:nil];
  
#warning TODO: localization
  self.title = @"Mentors";
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CEIUserTableViewCell"
                                             bundle:[NSBundle mainBundle]]
       forCellReuseIdentifier:kCellIdentifierMentor];
  
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  [self fetchMentors];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  __weak typeof(self) weakSelf = self;
  [self.tableView addPullToRefreshActionHandler:^{
    
    [weakSelf fetchMentors];
  }
                          ProgressImagesGifName:@"run@2x.gif"
                           LoadingImagesGifName:@"run@2x.gif"
                        ProgressScrollThreshold:60
                          LoadingImageFrameRate:30];
}

- (void)fetchMentors{
  
  __weak CEIMentorsViewController *weakSelf = self;
  
  if ([PFUser currentUser]) {
    
    PFQuery *query = [PFQuery mentors];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      [weakSelf.tableView stopRefreshAnimation];
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayMentors = [NSMutableArray arrayWithArray:objects];
        [weakSelf.tableView reloadData];
      }
    }];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kSegueIdentifierMentorsToMissions]) {
    
    ((CEIMissionsViewController *)segue.destinationViewController).user = [self.arrayMentors objectAtIndex:self.indexPathSelected.row];
    ((CEIMissionsViewController *)segue.destinationViewController).isMentor = NO;
  }
  else
    if ([segue.identifier isEqualToString:kIdentifierSegueMentorsToAddUser]) {
      
      ((CEIAddUserViewController *)segue.destinationViewController).isMentor = YES;
    }
}

#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  return kHeightUserCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayMentors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierMentor
                                                               forIndexPath:indexPath];
  
  PFUser *user = [self.arrayMentors objectAtIndex:indexPath.row];
  
  [cell configureWithUser:user];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  self.indexPathSelected = indexPath;
  [self performSegueWithIdentifier:kSegueIdentifierMentorsToMissions
                            sender:self];
}

#pragma mark - Notification Handling

- (void)handleNotificationMentorAdded:(NSNotification *)paramNotification{
  
  [self.arrayMentors addObject:paramNotification.object];
  [self.tableView reloadData];
}

@end
