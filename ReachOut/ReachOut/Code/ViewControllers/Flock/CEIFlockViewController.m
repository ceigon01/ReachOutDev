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
#import "SVPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "CEIDoubleDisclosureCell.h"
#import "CEIMissionsViewController.h"

static NSString *const kCellIdentifierFollower = @"kCellIdentifierFollower";
static NSString *const kSegueIdentifierFlockToMissions = @"kSegueIdentifier_Flock_Missions";

@interface CEIFlockViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;
@property (nonatomic, strong) NSArray *arrayFlock;

- (void)fetchFlock;

@end

@implementation CEIFlockViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localization
  self.title = @"Flock";
  
  self.tableView.pullToRefreshView.titleLabel.text = @"Gathering your flock...";
  
  __weak CEIFlockViewController *weakSelf = self;
  [self.tableView addPullToRefreshWithActionHandler:^{
    
    [weakSelf fetchFlock];
  }];
  
  [weakSelf fetchFlock];
}

- (void)fetchFlock{
  
  __weak CEIFlockViewController *weakSelf = self;
  
  PFQuery *query = [PFUser query];
  if (query && [PFUser currentUser]) {
   
    [query whereKey:@"mentorID" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      if (error) {
        
#warning TODO: handle error
        NSLog(@"%@",error);
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

- (int)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
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
