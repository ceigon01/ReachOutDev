//
//  CEIMoreViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 11.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMoreViewController.h"
#import <Parse/Parse.h>
#import "CEINotificationNames.h"
#import "CEIWebViewViewController.h"

typedef NS_ENUM(NSInteger, CEIMoreRow){

  CEIMoreRowAbout = 0,
  CEIMoreRowLogout = 1,
};
static const NSInteger kNumberOfMoreRows = 2;

static NSString *const kIdentifierCellMore = @"kIdentifierCellMore";
static NSString *const kIdentifierSegueMoreToWebViewCeigon = @"kIdentifierSegueMoreToWebViewCeigon";
static NSString *const kURLWebsiteCEIGON = @"http://www.ceigon.com/";
static NSString *const kTitleWebsiteCEIGON = @"CEIGON";

@interface CEIMoreViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation CEIMoreViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localization
  self.title = @"More";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueMoreToWebViewCeigon]) {
    
    [(CEIWebViewViewController *)segue.destinationViewController loadURL:[NSURL URLWithString:kURLWebsiteCEIGON]
                                                               withTitle:kTitleWebsiteCEIGON];
  }
}

#pragma mark - UITableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
  return kNumberOfMoreRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierCellMore
                                                          forIndexPath:indexPath];
  
 
  cell.textLabel.text = [self rowNameForIndexPath:indexPath];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  switch (indexPath.row) {
    case CEIMoreRowAbout:{
      
      [self performSegueWithIdentifier:kIdentifierSegueMoreToWebViewCeigon sender:self];
      break;
    }
      
    case CEIMoreRowLogout:{
      
      [[[UIAlertView alloc] initWithTitle:@"Logout"
                                  message:@"Are you sure?"
                                 delegate:self
                        cancelButtonTitle:@"Nope"
                        otherButtonTitles:@"Yup", nil]
       show];
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  if (buttonIndex != alertView.cancelButtonIndex) {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLogout
                                                        object:nil];
    [PFUser logOut];
  }
}

#pragma mark - Convinience Methods

- (NSString *)rowNameForIndexPath:(NSIndexPath *)paramIndexPath{

#warning TODO: localization
  switch (paramIndexPath.row) {
    case CEIMoreRowAbout: return @"About";
    case CEIMoreRowLogout: return @"Logout";
      
    default:  return @"Name missing";
  }
}

@end
