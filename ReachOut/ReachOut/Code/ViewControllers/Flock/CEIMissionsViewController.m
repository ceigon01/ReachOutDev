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
#import "SVPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Difference.h"
#import "CEIMissionViewController.h"

static NSString *const kSegueIdentifierMissionsToMission = @"kSegueIdentifier_Missions_Mission";
static NSString *const kCellIdentifierMissions = @"kCellIdentifierMissions";

@interface CEIMissionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayMissions;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;

- (void)fetchMissions;

@end

@implementation CEIMissionsViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localization
  self.title = @"Missions";
  
  self.tableView.pullToRefreshView.titleLabel.text = @"Gathering missions...";
  
  __weak CEIMissionsViewController *weakSelf = self;
  [self.tableView addPullToRefreshWithActionHandler:^{
    
    [weakSelf fetchMissions];
  }];
  
  [weakSelf fetchMissions];
}

- (void)fetchMissions{
  
  PFQuery *query = [PFQuery queryWithClassName:@"Mission"];
  if ([PFUser currentUser][@"isMentor"]) {
    
    [query whereKey:@"userIDAsignee" equalTo:self.user.objectId];
    [query whereKey:@"userIDReporter" equalTo:[PFUser currentUser].objectId];
  }
  else{
    
    [query whereKey:@"userIDReporter" equalTo:self.user.objectId];
    [query whereKey:@"userIDAsignee" equalTo:[PFUser currentUser].objectId];
  }
  
  __weak CEIMissionsViewController *weakSelf = self;
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    if (error) {
      
#warning TODO: handle error
      NSLog(@"%@",error);
    }
    else {
      
      weakSelf.arrayMissions = [NSArray arrayWithArray:objects];
      [weakSelf.tableView reloadData];
    }
  }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kSegueIdentifierMissionsToMission]) {
    
    ((CEIMissionViewController *)segue.destinationViewController).mission = [self.arrayMissions objectAtIndex:self.indexPathSelected.row];
  }
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
  
  cell.labelCounter.text = [NSString stringWithFormat:@"%ld",(long)daysDifference];
  cell.labelDate.text = @"Days";
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  self.indexPathSelected = indexPath;
}

@end
