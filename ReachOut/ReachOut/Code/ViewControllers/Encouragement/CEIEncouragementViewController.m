//
//  CEIEncouragementViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIEncouragementViewController.h"
#import <Parse/Parse.h>
#import "CEIEncouragementTableViewCell.h"
#import "UIScrollView+UzysAnimatedGifPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "CEIAlertView.h"
#import "CEIAddEncouragementViewController.h"

static const CGFloat kHeightCellOffset = 70.0f;

typedef NS_ENUM(NSInteger, CEIEncouragementType){
  
  CEIEncouragementTypeSent = 0,
  CEIEncouragementTypeReceived = 1,
};

static NSString *const kIdentifierCellEncouragement = @"kIdentifierCellEncouragement";

@interface CEIEncouragementViewController () <UITableViewDataSource, UITableViewDelegate>

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
  self.title = @"Encouragement";
  
  self.automaticallyAdjustsScrollViewInsets = NO;
  [self fetchEncouragementsReceived];
  [self fetchEncouragementsSent];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
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
  
  [query whereKey:@"followerID" equalTo:[PFUser currentUser]];
  [query includeKey:@"mentorID"];
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
  
  self.encouragementNew = [PFObject objectWithClassName:@"Encouragement"];
  
  if (vc.textView.text.length == 0) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put an Encouragement"];
    return NO;
  }
  else {
    
    self.encouragementNew[@"caption"] = vc.textView.text;
  }
  
  if (vc.indexPathSelectedFollower == nil) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Select a Follower to Encourage"];
    return NO;
  }
  
  __block PFUser *userFollowerSelected = [vc.arrayFollowers objectAtIndex:vc.indexPathSelectedFollower.row];
  
  self.encouragementNew[@"mentorID"] = [PFUser currentUser];
  self.encouragementNew[@"followerID"] = userFollowerSelected;
  
  __weak CEIEncouragementViewController *weakSelf = self;
  
  [self.encouragementNew saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else {
    
      PFQuery *query = [PFInstallation query];
      [query whereKey:@"user" equalTo:userFollowerSelected];
      
      [PFPush sendPushMessageToQueryInBackground:query withMessage:[NSString stringWithFormat:@"%@: %@",[PFUser currentUser][@"fullName"],vc.textView.text]];
      
      [weakSelf.arraySent addObject:weakSelf.encouragementNew];
      weakSelf.encouragementNew = nil;
      [weakSelf.tableView reloadData];
    }
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
  
  CGSize maximumLabelSize = CGSizeMake(tableView.frame.size.width, 9999.9f);
  
  NSArray *array = (self.segmentControll.selectedSegmentIndex == CEIEncouragementTypeSent) ? self.arraySent : self.arrayReceived;
  
  PFObject *encouragement = [array objectAtIndex:indexPath.row];
  NSString *caption = encouragement[@"caption"];
  
#warning TODO: hardcoded & deprecated :/
  CGSize expectedLabelSize = [caption sizeWithFont:[UIFont systemFontOfSize:17]
                                 constrainedToSize:maximumLabelSize
                                     lineBreakMode:NSLineBreakByTruncatingTail];
  
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
    cell.labelTitle.text = @"";
  }
  
  __weak CEIEncouragementTableViewCell *weakCell = cell;
  
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
  
  cell.labelCaption.text = encouragement[@"caption"];
  cell.labelFullName.text = user[@"username"];

  if (encouragement[@"dateRead"]) {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    cell.labelDateRead.text = [NSString stringWithFormat:@"read: %@",[dateFormatter stringFromDate: encouragement[@"dateRead"]]];
  }
  else {
    
#warning TODO
    cell.labelDateRead.text = @"not read yet";
  }
  
  cell.constraintHeightLabelCaption.constant = cell.frame.size.height - kHeightCellOffset;
  
  return cell;
}

#pragma mark - Action Handling

- (IBAction)valueChangeSegmentedControll:(id)sender{
  
  [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                withRowAnimation:UITableViewRowAnimationTop];
}

@end
