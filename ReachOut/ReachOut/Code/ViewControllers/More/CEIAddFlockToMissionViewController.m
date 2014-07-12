//
//  CEIAddFlockToMissionViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 23.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddFlockToMissionViewController.h"
#import <Parse/Parse.h>
#import "CEIAlertView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const kCellIdentifierAddFlockToMission = @"kCellIdentifierAddFlockToMission";

@interface CEIAddFlockToMissionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *arrayAllFollowers;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation CEIAddFlockToMissionViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  [self.tableView registerClass:[UITableViewCell class]
         forCellReuseIdentifier:kCellIdentifierAddFlockToMission];
  
  [self fetchFlock];
}

- (void)fetchFlock{
  
  __weak typeof (self) weakSelf = self;
  
  PFQuery *query = [PFUser query];
  if (query && [PFUser currentUser]) {
    
    [query whereKey:@"mentors" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayAllFollowers = [NSArray arrayWithArray:objects];
        [weakSelf.tableView reloadData];
      }
    }];
  }
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayAllFollowers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierAddFlockToMission
                                                          forIndexPath:indexPath];
  
  PFUser *user = [self.arrayAllFollowers objectAtIndex:indexPath.row];
  
  
  if (user[@"image"]) {
    
    PFFile *file = user[@"image"];
    
    __weak UITableViewCell *weakCell = cell;
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
      
      weakCell.imageView.image = [UIImage imageWithData:data];
      weakCell.imageView.layer.cornerRadius = weakCell.contentView.frame.size.height * 0.5f;
      weakCell.imageView.layer.masksToBounds = YES;
    }];
    
  }
  else{
    
    cell.imageView.image = [UIImage imageNamed:@"sheepPhoto"];
    cell.imageView.layer.cornerRadius = cell.contentView.frame.size.height * 0.5f;
    cell.imageView.layer.masksToBounds = YES;
  }

  cell.textLabel.text = user[@"fullName"];
  
  if ([self.arrayFollowersSelected containsObject:user]) {
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
  else{
    
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  PFUser *user = [self.arrayAllFollowers objectAtIndex:indexPath.row];
  
  if ([self.arrayFollowersSelected containsObject:user]) {
    
    [self.arrayFollowersSelected removeObject:user];
  }
  else{
    
    [self.arrayFollowersSelected addObject:user];
  }
  
  [tableView reloadRowsAtIndexPaths:@[indexPath]
                   withRowAnimation:UITableViewRowAnimationFade];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Lazy Getters

- (NSMutableArray *)arrayFollowersSelected{
  
  if (_arrayFollowersSelected == nil) {
    
    _arrayFollowersSelected = [[NSMutableArray alloc] init];
  }
  
  return _arrayFollowersSelected;
}

- (NSArray *)arrayAllFollowers{
  
  if (_arrayAllFollowers == nil) {
    
    _arrayAllFollowers = [[NSArray alloc] init];
  }
  
  return _arrayAllFollowers;
}

@end
