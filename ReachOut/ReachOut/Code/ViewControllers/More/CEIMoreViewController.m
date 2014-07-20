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
#import "CEIMyProfileViewController.h"
#import "CEIAlertView.h"

typedef NS_ENUM(NSInteger, CEIMoreRow){
  
  CEIMoreRowMissions = 0,
  CEIMoreRowUpdateProfile = 1,
  CEIMoreRowAbout = 2,
  CEIMoreRowMotto = 3,
  CEIMoreRowLogout = 4,
};
static const NSInteger kNumberOfMoreRows = 5;

static NSString *const kIdentifierCellMore = @"kIdentifierCellMore";
static NSString *const kIdentifierSegueMoreToWebViewCeigon = @"kIdentifierSegueMoreToWebViewCeigon";
static NSString *const kIdentifierSegueMoreToAllMissions = @"kIdentifierSegueMoreToAllMissions";
static NSString *const kIdentifierSegueMoreToMotto = @"kIdentifierSegueMoreToMotto";
static NSString *const kIdentifierSegueMoreToMyProfile = @"kIdentifierSegueMoreToMyProfile";

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

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{
  
  if ([fromViewController isKindOfClass:[CEIMyProfileViewController class]]) {
    
    CEIMyProfileViewController *vc = (CEIMyProfileViewController *)fromViewController;
    
#warning TODO: localizations
    if (vc.textFieldFullName.text.length == 0){
      
      [CEIAlertView showAlertViewWithValidationMessage:@"Please tell us your name"];
      return NO;
    }
    else
      if (![vc.textFieldPassword.text isEqualToString:vc.textFieldPasswordRetype.text]){
        
        [CEIAlertView showAlertViewWithValidationMessage:@"Passwords do not match"];
        return NO;
      }
      else{
          
          PFUser *user = [PFUser currentUser];
          
          user.password = vc.textFieldPassword.text;
          user[@"fullName"] = vc.textFieldFullName.text;
          user[@"title"] = vc.textFieldTitle.text;

        if (vc.imageChanged) {
          
          UIImage *image = [vc.buttonUserImage backgroundImageForState:vc.buttonUserImage.state];
          PFFile *file = [PFFile fileWithData:UIImagePNGRepresentation(image)];
          user[@"image"] = file;
        }
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
          if (error) {
      
            [CEIAlertView showAlertViewWithError:error];
          }
          else{
      
          }
        }];
      }
  }
  
  return YES;
}

- (IBAction)unwindMotto:(UIStoryboardSegue *)unwindSegue{
  
}

- (IBAction)unwindMyProfile:(UIStoryboardSegue *)unwindSegue{
  
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
    case CEIMoreRowMissions:{
      
      [self performSegueWithIdentifier:kIdentifierSegueMoreToAllMissions sender:self];
      break;
    }
    
    case CEIMoreRowAbout:{
      
      [self performSegueWithIdentifier:kIdentifierSegueMoreToWebViewCeigon sender:self];
      break;
    }
      
    case CEIMoreRowMotto:{
      
      [self performSegueWithIdentifier:kIdentifierSegueMoreToMotto sender:self];
      break;
    }
      
    case CEIMoreRowUpdateProfile:{
      
      [self performSegueWithIdentifier:kIdentifierSegueMoreToMyProfile sender:self];
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
    case CEIMoreRowMissions: return @"Missions";
    case CEIMoreRowUpdateProfile: return @"Update Profile";
    case CEIMoreRowAbout: return @"About";
    case CEIMoreRowMotto: return @"Motto";
    case CEIMoreRowLogout: return @"Logout";
      
    default:  return @"Name missing";
  }
}

@end
