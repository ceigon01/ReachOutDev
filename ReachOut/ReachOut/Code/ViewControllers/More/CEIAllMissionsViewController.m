//
//  CEIAllMissionsViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 23.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAllMissionsViewController.h"
#import "CEIAlertView.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "CEIDoubleDisclosureCell.h"
#import <Parse/Parse.h>
#import "CEIAddMissionViewController.h"

static NSString *const kIdentifierCellAllMissionsToAddMission = @"kIdentifierCellAllMissionsToAddMission";

@interface CEIAllMissionsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *arrayMissions;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;

@end

@implementation CEIAllMissionsViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  self.indexPathSelected = nil;
  
  [self fetchMissions];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  __weak typeof(self) weakSelf = self;
  [self.tableView addPullToRefreshActionHandler:^{
    
    [weakSelf fetchMissions];
  }
                          ProgressImagesGifName:@"run@2x.gif"
                           LoadingImagesGifName:@"run@2x.gif"
                        ProgressScrollThreshold:60
                          LoadingImageFrameRate:30];
}

- (void)fetchMissions{
  
  PFQuery *query = [PFQuery queryWithClassName:@"Mission"];
    
  [query whereKey:@"userReporter" equalTo:[PFUser currentUser]];
  
  __weak CEIAllMissionsViewController *weakSelf = self;
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [weakSelf.tableView stopRefreshAnimation];
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else {
      
      weakSelf.arrayMissions = [NSMutableArray arrayWithArray:objects];
      [weakSelf.tableView reloadData];
    }
  }];
}

- (void)notificationMissionAdded:(id)paramNotification{
  
  if ([paramNotification isKindOfClass:[NSNotification class]]) {
    
    NSNotification *notification = (NSNotification *)paramNotification;
   
    [self.arrayMissions addObject:notification.object];
    [self.tableView reloadData];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqual:kIdentifierCellAllMissionsToAddMission] && self.indexPathSelected != nil) {
   
    ((CEIAddMissionViewController *)segue.destinationViewController).mission = [self.arrayMissions objectAtIndex:self.indexPathSelected.row];
    self.indexPathSelected = nil;
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{
  
  if ([fromViewController isKindOfClass:[CEIAddMissionViewController class]]) {
    
    CEIAddMissionViewController *addMissionViewController = (CEIAddMissionViewController *)fromViewController;
    
    PFObject *mission = addMissionViewController.mission;
    
    PFFile *fileImage = mission[@"image"];
    if (fileImage == nil) {
      
      [CEIAlertView showAlertViewWithValidationMessage:@"Please use a background image."];
      return NO;
    }

    NSString *caption = mission[@"caption"];
    if (caption.length < 1) {
      
      [CEIAlertView showAlertViewWithValidationMessage:@"Please put a caption."];
      return NO;
    }
    
    BOOL isNeverending = [mission[@"isNeverending"] boolValue];
    NSString *timeCount = mission[@"timeCount"];
    if (!isNeverending && timeCount.length < 1) {
      
      [CEIAlertView showAlertViewWithValidationMessage:@"Please set length of your mission, or select \'Never ending mission\'."];
      return NO;
    }
    
    if (addMissionViewController.arrayFlock.count == 0) {
      
      [CEIAlertView showAlertViewWithValidationMessage:@"Please select followers, that you want on this mission."];
      return NO;
    }
    
    if (addMissionViewController.arrayGoals.count == 0) {
      
      [CEIAlertView showAlertViewWithValidationMessage:@"Please set some goals."];
      return NO;
    }
    
    __weak typeof (self) weakSelf = self;
    
    mission[@"dateBegins"] = [NSDate date];
    mission[@"userReporter"] = [PFUser currentUser];
    mission[@"asigneesCount"] = [NSNumber numberWithInt:addMissionViewController.arrayFlock.count];
    [mission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      
      [weakSelf.arrayMissions addObject:mission];
      [weakSelf.tableView reloadData];
    }];
  }
  
  return YES;
}


- (IBAction)unwindAddMission:(UIStoryboardSegue *)unwindSegue{
  
  NSLog(@"did unwind add mission");
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayMissions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIDoubleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellAllMissionsToAddMission
                                                                  forIndexPath:indexPath];
  
  PFObject *mission = [self.arrayMissions objectAtIndex:indexPath.row];
  
  cell.textLabel.text = mission[@"caption"];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",mission[@"asigneesCount"]];
  cell.labelLowerDetail.text = @"Followers";
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  self.indexPathSelected = indexPath;
}

@end
