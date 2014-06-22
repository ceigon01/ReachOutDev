//
//  CEIAddEncouragementViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddEncouragementViewController.h"
#import "UIImageView+WebCache.h"
#import "CEIAlertView.h"

static NSString *const kIdentifierCellAddEncouragement = @"kIdentifierCellAddEncouragement";

@interface CEIAddEncouragementViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation CEIAddEncouragementViewController

- (void)viewDidLoad{
  [super viewDidLoad];
 
  __weak CEIAddEncouragementViewController *weakSelf = self;
  
  PFQuery *query = [PFUser query];
  if (query && [PFUser currentUser]) {
    
    [query whereKey:@"mentorID" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
      if (error) {

        [CEIAlertView showAlertViewWithError:error];
      }
      else{
        
        weakSelf.arrayFollowers = [NSArray arrayWithArray:objects];
        weakSelf.indexPathSelectedFollower = nil;
        [weakSelf.tableView reloadData];
      }
    }];
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
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
  
  textView.text = @"";
  textView.textColor = [UIColor blackColor];
  return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
  
  if (textView.text.length == 0){
    
#warning TODO: localization
    textView.textColor = [UIColor lightGrayColor];
    textView.text = @"Put your Encouragement here.";
    [textView resignFirstResponder];
  }
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return self.arrayFollowers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellAddEncouragement
                                                          forIndexPath:indexPath];
  
  PFUser *user = [self.arrayFollowers objectAtIndex:indexPath.row];
  
  if (user[@"imageURL"]) {
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:user[@"imageURL"]]];
  }
  else {

    cell.imageView.image = [UIImage imageNamed:@"imgUserPlaceholder"];
  }
  
  cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height * 0.5f;
  cell.imageView.layer.masksToBounds = YES;
  cell.textLabel.text = user[@"fullName"];
  
  cell.accessoryType = ([self.indexPathSelectedFollower compare:indexPath] == NSOrderedSame) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [self.textView resignFirstResponder];
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (self.indexPathSelectedFollower) {
    
    [tableView reloadRowsAtIndexPaths:@[self.indexPathSelectedFollower]
                     withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView cellForRowAtIndexPath:self.indexPathSelectedFollower].accessoryType = UITableViewCellAccessoryNone;
  }
  
  self.indexPathSelectedFollower = indexPath;
  

  [tableView reloadRowsAtIndexPaths:@[self.indexPathSelectedFollower]
                   withRowAnimation:UITableViewRowAnimationFade];
  [self.tableView cellForRowAtIndexPath:self.indexPathSelectedFollower].accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - Lazy Getters

- (NSArray *)arrayFollowers{
  
  if (_arrayFollowers == nil){
    
    _arrayFollowers = [[NSArray alloc] init];
  }
  
  return _arrayFollowers;
}
   
@end
