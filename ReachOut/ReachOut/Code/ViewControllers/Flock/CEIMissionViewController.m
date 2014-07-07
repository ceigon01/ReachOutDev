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

static NSString *const kIdentifierCellMission = @"kIdentifierCellMission";
static const CGFloat kHeightFooter = 20.0f;

@interface CEIMissionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageViewBackgroud;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UILabel *labelUserName;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionName;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionDuration;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *arrayGoals;
@property (nonatomic, strong) NSArray *arrayGoalSteps;

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

  self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.height * 0.5f;
  self.imageViewProfile.layer.masksToBounds = YES;
  
#warning TODO: url -> file
  if (self.user[@"imageURL"]){
  
    [self.imageViewProfile setImageWithURL:[NSURL URLWithString:self.user[@"imageURL"]]
                   placeholderImage:[UIImage imageNamed:@"sheepPhoto"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                            
                            weakSelf.imageViewProfile.layer.cornerRadius = weakSelf.imageViewProfile.frame.size.height * 0.5f;
                            weakSelf.imageViewProfile.layer.masksToBounds = YES;
                          }];
  }
  else{
    
    self.imageViewProfile.image = [UIImage imageNamed:@"sheepPhoto"];
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

@end
