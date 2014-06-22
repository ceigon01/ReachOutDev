//
//  CEIFlockViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 09.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIFlockViewController.h"
#import <Parse/Parse.h>
#import "CEIAlertView.h"
#import "UIImageView+WebCache.h"
#import "CEIDoubleDisclosureCell.h"
#import "CEIMissionsViewController.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"

static NSString *const kCellIdentifierFollower = @"kCellIdentifierFollower";
static NSString *const kSegueIdentifierFlockToMissions = @"kSegueIdentifier_Flock_Missions";

@interface CEIFlockViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;
@property (nonatomic, strong) NSArray *arrayFlock;
//@property (nonatomic, strong) UIRefreshControl *refreshControll;

- (void)fetchFlock;

@end

@implementation CEIFlockViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localization
  self.title = @"Flock";
  
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
   
    [query whereKey:@"mentorID" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      [weakSelf.tableView stopRefreshAnimation];
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayFlock = [NSArray arrayWithArray:objects];
        [weakSelf.tableView reloadData];
      }
    }];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kSegueIdentifierFlockToMissions]) {
    
    ((CEIMissionsViewController *)segue.destinationViewController).user = [self.arrayFlock objectAtIndex:self.indexPathSelected.row];
  }
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayFlock.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIDoubleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierFollower
                                                                  forIndexPath:indexPath];
  
  PFUser *user = [self.arrayFlock objectAtIndex:indexPath.row];
  
  [cell.imageView setImageWithURL:user[@"imageURL"]
                 placeholderImage:[UIImage imageNamed:@"imgPlaceholder"]];
  
  cell.textLabel.text = user[@"fullName"];
#warning TODO: find value to be placed here
  cell.labelCounter.text = @"1/2";
#warning TODO: ...and here
  cell.labelDate.text = @"Yesterday";
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

  self.indexPathSelected = indexPath;
}

@end
