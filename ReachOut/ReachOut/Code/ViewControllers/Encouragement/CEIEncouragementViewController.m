//
//  CEIEncouragementViewController.m
//  ReachOut
//
//  Created by Jason Smith on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIEncouragementViewController.h"
#import <Parse/Parse.h>
#import "CEIEncouragementTableViewCell.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "CEIAlertView.h"
#import "CEIAddEncouragementViewController.h"

static const CGFloat kHeightCellOffset = 80.0f;

typedef NS_ENUM(NSInteger, CEIEncouragementType){
  
  CEIEncouragementTypeSent = 0,
  CEIEncouragementTypeReceived = 1,
};

static NSString *const kIdentifierCellEncouragement = @"kIdentifierCellEncouragement";

@interface CEIEncouragementViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>

@property (nonatomic, strong) PFObject *encouragementNew;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControll;

@property (nonatomic, strong) NSMutableArray *arraySent;
@property (nonatomic, strong) NSMutableArray *arrayReceived;

@end

@implementation CEIEncouragementViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localization
  self.title = @"Encourage";
  
  self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  [self fetchEncouragementsReceived];
  [self fetchEncouragementsSent];
  
  __weak typeof(self) weakSelf = self;
  [self.tableView addPullToRefreshActionHandler:^{
    
    [weakSelf fetchEncouragements];
  }
                          ProgressImagesGifName:@"run@2x.gif"
                           LoadingImagesGifName:@"run@2x.gif"
                        ProgressScrollThreshold:60
                          LoadingImageFrameRate:30];
}

- (void)fetchEncouragements{
  
  if (self.segmentControll.selectedSegmentIndex == CEIEncouragementTypeReceived) {
    
    [self fetchEncouragementsReceived];
  }
  else {
    
    [self fetchEncouragementsSent];
  }
}

- (void)fetchEncouragementsSent{
  
  __weak CEIEncouragementViewController *weakSelf = self;
  
  PFQuery *query = [PFQuery queryWithClassName:@"Encouragement"];
    
  [query whereKey:@"mentorID" equalTo:[PFUser currentUser]];
  [query includeKey:@"followerID"];
  [query orderByAscending:@"dateRead"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [weakSelf.tableView stopRefreshAnimation];
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else{
      
      weakSelf.arraySent = [NSMutableArray arrayWithArray:objects];
      [weakSelf.tableView reloadData];
    }
  }];
}

- (void)fetchEncouragementsReceived{
  
  __weak CEIEncouragementViewController *weakSelf = self;
  
  PFQuery *query = [PFQuery queryWithClassName:@"Encouragement"];

//  PFQuery *query1 = [PFUser query];
//  [query1 whereKey:@"followers" equalTo:[PFUser currentUser]];
//  PFQuery *query2 = [[[PFUser currentUser] relationForKey:@"mentors"] query];  
  
  [query whereKey:@"followerID" equalTo:[PFUser currentUser]];
  [query includeKey:@"mentorID"];
  [query orderByAscending:@"dateRead"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [weakSelf.tableView stopRefreshAnimation];
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else{
      
      weakSelf.arrayReceived = [NSMutableArray arrayWithArray:objects];
      [weakSelf.arrayReceived enumerateObjectsUsingBlock:^(PFObject *encouragement, NSUInteger idx, BOOL *stop) {
        
        if (encouragement[@"dateRead"] == nil) {
          
          encouragement[@"dateRead"] = [NSDate date];
          [encouragement saveInBackground];
        }
      }];
      [weakSelf.tableView reloadData];
    }
  }];
}

#pragma mark - Navigation

- (IBAction)unwindAddEncouragement:(UIStoryboardSegue *)unwindSegue{
  
  if ([unwindSegue.sourceViewController isKindOfClass:[CEIAddEncouragementViewController class]]) {
    
    [self.tableView reloadData];
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{
  
#warning TODO: localizations
  CEIAddEncouragementViewController *vc = nil;
  
  if ([fromViewController isKindOfClass:[CEIAddEncouragementViewController class]]) {
    
    vc = (CEIAddEncouragementViewController *)fromViewController;
  }
  else {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Shouldn't get here!"];
    return NO;
  }
  
  if (vc.encouragementInPlace == NO) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put an Encouragement"];
    return NO;
  }
  
  if (vc.arrayFollowersSelected.count == 0) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Select at least one Follower to Encourage"];
    return NO;
  }
  
  __weak typeof (self) weakSelf = self;
  
  [vc.arrayFollowersSelected enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
    
    PFObject *encouragement = [PFObject objectWithClassName:@"Encouragement"];
    
    encouragement[@"caption"] = vc.textView.text;
    encouragement[@"mentorID"] = [PFUser currentUser];
    encouragement[@"followerID"] = user;
    
    [encouragement saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      
      if (error) {
        
        [CEIAlertView showAlertViewWithError:error];
      }
      else {
        
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"user" equalTo:user];

        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%@: %@",[PFUser currentUser][@"fullName"],vc.textView.text], @"alert",
                                @"Increment", @"badge",
                                nil];
          
       PFPush *push = [[PFPush alloc] init];
       [push setChannels:[NSArray arrayWithObjects:@"PublicMessage", nil]];
       [push setData:data];
       [push setQuery:query];
       [push sendPushInBackground];
   
        [weakSelf.arraySent insertObject:encouragement atIndex:0];
        [weakSelf.tableView reloadData];
      }
    }];
  }];
  
  return YES;
}

#pragma mark - UITableViewDatasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return (self.segmentControll.selectedSegmentIndex == CEIEncouragementTypeReceived) ? self.arrayReceived.count : self.arraySent.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
#warning TODO: estimate height
  
  CGSize maximumLabelSize = CGSizeMake(250, 9999.9f);
  
  NSArray *array = (self.segmentControll.selectedSegmentIndex == CEIEncouragementTypeSent) ? self.arraySent : self.arrayReceived;
  
  PFObject *encouragement = [array objectAtIndex:indexPath.row];
  NSString *caption = encouragement[@"caption"];
  
#warning TODO: hardcoded & deprecated :/
  CGSize expectedLabelSize = [caption sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]
                                 constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
  
  return expectedLabelSize.height + kHeightCellOffset;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIEncouragementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellEncouragement
                                                                        forIndexPath:indexPath];
  
  PFObject *encouragement = nil;
  PFUser *user = nil;
  
  if (self.segmentControll.selectedSegmentIndex == CEIEncouragementTypeReceived) {
    
    encouragement = [self.arrayReceived objectAtIndex:indexPath.row];
    user = encouragement[@"mentorID"];
    cell.labelTitle.text = user[@"title"];
  }
  else {

    encouragement = [self.arraySent objectAtIndex:indexPath.row];
    user = encouragement[@"followerID"];
#warning TODO: title unnecessary?
    cell.labelTitle.text = user[@"title"];
  }
  
  if (user[@"image"]) {
    
    PFFile *file = user[@"image"];
    
    __weak CEIEncouragementTableViewCell *weakCell = cell;
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
      
      weakCell.imageViewProfile.image = [UIImage imageWithData:data];
        weakCell.imageViewProfile.layer.cornerRadius = weakCell.imageViewProfile.frame.size.height * 0.5f;
        weakCell.imageViewProfile.layer.masksToBounds = YES;
    }];
  }
  cell.labelCaption.numberOfLines = 0;
  cell.labelCaption.text = encouragement[@"caption"];
  cell.labelFullName.text = user[@"fullName"];

  if (encouragement[@"dateRead"]) {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    cell.labelDateRead.text = [NSString stringWithFormat:@"read: %@",[dateFormatter stringFromDate: encouragement[@"dateRead"]]];
  }
  else {

    cell.labelDateRead.text = @"not read yet";
  }
  
  cell.constraintHeightLabelCaption.constant = cell.frame.size.height - kHeightCellOffset;
  
  
  
  cell.delegate = self;
  
#warning TODO: localizations
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.backgroundColor = [UIColor redColor];
  [button setTitle:@"Delete" forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  button.tag = indexPath.row;
  
  [cell setRightUtilityButtons:@[
                                 button,
                                 ]];
  
  
  
  return cell;
}

#pragma mark - Action Handling

- (IBAction)valueChangeSegmentedControll:(id)sender{
  
  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
  
  NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
  
  __block NSMutableArray *array = (self.segmentControll.selectedSegmentIndex == CEIEncouragementTypeReceived) ?
  self.arrayReceived :
  self.arraySent;
  
  __weak typeof (self) weakSelf = self;
  
  PFObject *encouragement = [array objectAtIndex:cellIndexPath.row];
  
  [array removeObjectAtIndex:cellIndexPath.row];
  [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
  
  [encouragement deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
      [array addObject:encouragement];
      [weakSelf.tableView reloadData];
    }
  }];
}
@end
