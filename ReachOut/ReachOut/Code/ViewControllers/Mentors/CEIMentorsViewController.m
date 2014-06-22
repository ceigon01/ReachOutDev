//
//  CEIMentorsViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 09.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMentorsViewController.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import "CEIMissionsViewController.h"
#import "SVPullToRefresh.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const kCellIdentifierMentor = @"kCellIdentifierMentor";
static NSString *const kSegueIdentifierMentorsToMissions = @"kSegueIdentifier_Mentors_Missions";

@interface CEIMentorsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayMentors;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;

- (void)fetchMentors;

@end

@implementation CEIMentorsViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localization
  self.title = @"Mentors";
  
  self.tableView.pullToRefreshView.titleLabel.text = @"Gathering your flock...";
  
  __weak CEIMentorsViewController *weakSelf = self;
  [self.tableView addPullToRefreshWithActionHandler:^{
    
    [weakSelf fetchMentors];
  }];
  
  [weakSelf fetchMentors];
}

- (void)fetchMentors{
  
  __weak CEIMentorsViewController *weakSelf = self;
  
  PFQuery *query = [PFUser query];
  if (query && [PFUser currentUser] && [PFUser currentUser][@"mentorID"]) {
    
    [query whereKey:@"objectId" equalTo:[PFUser currentUser][@"mentorID"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      NSLog(@"%@",objects);
      
      if (error) {
        
#warning TODO: handle error
        NSLog(@"%@",error);
      }
      else{
        
        weakSelf.arrayMentors = [NSArray arrayWithArray:objects];
        [weakSelf.tableView reloadData];
      }
    }];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kSegueIdentifierMentorsToMissions]) {
    
    ((CEIMissionsViewController *)segue.destinationViewController).user = [self.arrayMentors objectAtIndex:self.indexPathSelected.row];
  }
}

#pragma mark - UITableView Delegate & Datasource

- (int)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayMentors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierMentor];
  
  PFUser *user = [self.arrayMentors objectAtIndex:indexPath.row];
  
  [cell.imageView setImageWithURL:[NSURL URLWithString:user[@"imageURL"]]
                 placeholderImage:[UIImage imageNamed:@"imgPlaceholder"]];
  cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height * 0.5f;
  cell.imageView.layer.masksToBounds = YES;
  cell.textLabel.text = user[@"title"];
  cell.detailTextLabel.text = user[@"fullName"];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  self.indexPathSelected = indexPath;
}

@end
