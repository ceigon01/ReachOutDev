//
//  CEIAddEncouragementViewController.m
//  ReachOut
//
//  Created by Jason Smith on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddEncouragementViewController.h"
#import "UIImageView+WebCache.h"
#import "CEIAlertView.h"
#import "CEIUserTableViewCell.h"
#import "PFQuery+FollowersAndMentors.h"

static NSString *const kIdentifierCellAddEncouragement = @"kIdentifierCellAddEncouragement";

@interface CEIAddEncouragementViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation CEIAddEncouragementViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CEIUserTableViewCell"
                                             bundle:[NSBundle mainBundle]]
       forCellReuseIdentifier:kIdentifierCellAddEncouragement];
  
  self.encouragementInPlace = NO;
  
  if (self.arrayFollowersAvailable.count == 0) {
  
    __weak CEIAddEncouragementViewController *weakSelf = self;
    
    PFQuery *query = [PFQuery followers];
    if (query && [PFUser currentUser]) {
      
      [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
          
          [CEIAlertView showAlertViewWithError:error];
        }
        else{
          
          weakSelf.arrayFollowersAvailable = [NSMutableArray arrayWithArray:objects];
          [weakSelf.tableView reloadData];
        }
      }];
    }
  }
  
#warning TODO: localization
  self.textView.text = @"Put your Encouragement here.";
  self.textView.textColor = [UIColor lightGrayColor];
  self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.textView.layer.borderWidth = 0.5f;
  self.textView.layer.cornerRadius = 4.0f;
}

#pragma mark - UITextView Delegate

- (void)textViewDidEndEditing:(UITextView *)textView{
  
  [textView resignFirstResponder];
  if (textView.text.length == 0){
    
#warning TODO: localization
    textView.textColor = [UIColor lightGrayColor];
    textView.text = @"Put your Encouragement here.";
    self.encouragementInPlace = NO;
    [textView resignFirstResponder];
  }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
  
  textView.text = @"";
  textView.textColor = [UIColor blackColor];
  self.encouragementInPlace = YES;
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
  
  if (textView.text.length == 0){
    
#warning TODO: localization
    textView.textColor = [UIColor lightGrayColor];
    textView.text = @"Put your Encouragement here.";
    self.encouragementInPlace = NO;
    [textView resignFirstResponder];
  }
}

#pragma mark - UITableView Datasource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  return kHeightUserCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayFollowersAvailable.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  CEIUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellAddEncouragement
                                                               forIndexPath:indexPath];
  
  PFUser *user = [self.arrayFollowersAvailable objectAtIndex:indexPath.row];
  
  [cell configureWithUser:user];
  
  NSInteger selected = [self.arrayFollowersSelected indexOfObject:user];
  
  cell.accessoryType = (selected == NSNotFound) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [self.textView resignFirstResponder];
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  PFUser *user = [self.arrayFollowersAvailable objectAtIndex:indexPath.row];
  
  if ([self.arrayFollowersSelected indexOfObject:user] == NSNotFound) {
    
    [self.arrayFollowersSelected addObject:user];
  }
  else{
    
    [self.arrayFollowersSelected removeObject:user];
  }
  
  [tableView reloadRowsAtIndexPaths:@[indexPath]
                   withRowAnimation:UITableViewRowAnimationFade];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Lazy Getters

- (NSMutableArray *)arrayFollowersSelected{
  
  if (_arrayFollowersSelected == nil){
    
    _arrayFollowersSelected = [[NSMutableArray alloc] init];
  }
  
  return _arrayFollowersSelected;
}


- (NSMutableArray *)arrayFollowersAvailable{
  
  if (_arrayFollowersAvailable == nil){
    
    _arrayFollowersAvailable = [[NSMutableArray alloc] init];
  }
  
  return _arrayFollowersAvailable;
}

@end
