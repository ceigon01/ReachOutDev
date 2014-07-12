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
   
    [query whereKey:@"mentors" equalTo:[PFUser currentUser]];
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
    ((CEIMissionsViewController *)segue.destinationViewController).mentor = YES;
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
  
  __weak UITableViewCell *weakCell = cell;
  
  if (user[@"imageURL"]) {
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:user[@"imageURL"]]
                   placeholderImage:[UIImage imageNamed:@"sheepPhoto"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                            
                            weakCell.imageView.layer.cornerRadius = weakCell.contentView.frame.size.height * 0.5f;
                            weakCell.imageView.layer.masksToBounds = YES;
                          }];
  }
  else{
    
    cell.imageView.image = [UIImage imageNamed:@"sheepPhoto"];
  }
  
  cell.imageView.layer.cornerRadius = cell.contentView.frame.size.height * 0.5f;
  cell.imageView.layer.masksToBounds = YES;
  
#warning TODO: implement?
  cell.textLabel.text = user[@"fullName"];
  cell.detailTextLabel.text = @"";//@"detail";
  cell.labelLowerDetail.text = @"";//@"lower detail";
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

  self.indexPathSelected = indexPath;
  [self performSegueWithIdentifier:kSegueIdentifierFlockToMissions
                            sender:self];
}

@end
