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

static NSString *const kIdentifierCellMission = @"kIdentifierCellMission";
static const CGFloat kHeightFooter = 20.0f;

@interface CEIMissionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageViewBackgroud;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionName;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionDuration;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *arrayGoals;

@end

@implementation CEIMissionViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [self.tableView registerClass:[CEIGoalTableViewCell class]
         forCellReuseIdentifier:kIdentifierCellMission];
  
  [self fetchGoals];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  __weak typeof(self) weakSelf =self;
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
  
  PFQuery *query = [PFQuery queryWithClassName:@"Goal"];
  if (query && [PFUser currentUser]) {
    
    [query whereKey:@"mission" equalTo:self.mission];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      [weakSelf.tableView stopRefreshAnimation];
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayGoals = [NSArray arrayWithArray:objects];
        [weakSelf.tableView reloadData];
      }
    }];
  }
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return self.arrayGoals.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIGoalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellMission];
  
  PFObject *goal = [self.arrayGoals objectAtIndex:indexPath.section];
  
  cell.textLabel.text = goal[@"caption"];
  
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
  
  NSDate *dateFrom = goal[@"dateFrom"];
  NSDate *dateTo = goal[@"dateTo"];
  
  NSInteger numberOfDaysTotal = [dateFrom daysBetweenDate:dateTo];
  NSInteger numberOfDaysSoFar = [[NSDate date] daysBetweenDate:dateTo];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             tableView.frame.size.width,
                                                             kHeightFooter)];
  label.text = [NSString stringWithFormat:@"%d %% of goal",(numberOfDaysSoFar * 100 / numberOfDaysTotal)];
  label.textAlignment = NSTextAlignmentRight;
  
  return label;
}

@end
