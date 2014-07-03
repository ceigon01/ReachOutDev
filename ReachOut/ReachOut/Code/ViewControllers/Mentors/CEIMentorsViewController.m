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
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import <QuartzCore/QuartzCore.h>
#import "CEIAlertView.h"

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
  
  PFQuery *query = [PFUser query];
  if (query && [PFUser currentUser] && [PFUser currentUser][@"mentorID"]) {
    
    [query whereKey:@"objectId" equalTo:[PFUser currentUser][@"mentorID"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      [weakSelf.tableView stopRefreshAnimation];
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
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
    ((CEIMissionsViewController *)segue.destinationViewController).mentor = NO;
  }
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayMentors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierMentor
                                                          forIndexPath:indexPath];
  
  __weak UITableViewCell *weakCell = cell;
  
  PFUser *user = [self.arrayMentors objectAtIndex:indexPath.row];
  
  if (user[@"imageURL"]) {
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:user[@"imageURL"]]
                   placeholderImage:[UIImage imageNamed:@"sheepPhoto"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

                            weakCell.imageView.layer.cornerRadius = weakCell.imageView.frame.size.height * 0.5f;
                            weakCell.imageView.layer.masksToBounds = YES;
                          }];
  }
  else{
    
    cell.imageView.image = [UIImage imageNamed:@"sheepPhoto"];
  }
  
  cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height * 0.5f;
  cell.imageView.layer.masksToBounds = YES;
  
  cell.textLabel.text = user[@"fullName"];
  cell.detailTextLabel.text = user[@"title"];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
  
  cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height * 0.5f;
  cell.imageView.layer.masksToBounds = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  self.indexPathSelected = indexPath;
  
  [self performSegueWithIdentifier:kSegueIdentifierMentorsToMissions
                            sender:self];
}

@end
