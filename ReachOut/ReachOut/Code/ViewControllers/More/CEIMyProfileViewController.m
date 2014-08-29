//
//  CEIMyProfileViewController.m
//  ReachOut
//
//  Created by Jason Smith on 16.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMyProfileViewController.h"
#import <Parse/Parse.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PFQuery+FollowersAndMentors.h"
#import "CEIAlertView.h"

#warning TODO: redundant
NSString *const kTitleButtonImageSourceCameraRollCameraRoll4 = @"Camera roll";
NSString *const kTitleButtonImageSourceCameraRollTakeAPicture4 = @"Take a picture";

@interface CEIMyProfileViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) BOOL didEdit;

@end

@implementation CEIMyProfileViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  self.slideToOriginAfterTap = YES;
  self.imageChanged = NO;
  
  PFUser *userCurrent = [PFUser currentUser];
  
  self.textFieldTitle.text = userCurrent[@"title"];
  self.textFieldFullName.text = userCurrent[@"fullName"];
  
  NSString *prefix = userCurrent[@"phonePrefix"] ? userCurrent[@"phonePrefix"] : @"-";
  NSString *phoneNumber = userCurrent[@"mobilePhone"] ? userCurrent[@"mobilePhone"] : @"-";
  
  self.labelPhoneNumber.text = [NSString stringWithFormat:@"Phone number: +(%@) %@",prefix,phoneNumber];
  
  self.buttonUserImage.layer.cornerRadius = self.buttonUserImage.frame.size.width * 0.5f;
  self.buttonUserImage.layer.borderColor = [UIColor whiteColor].CGColor;
  self.buttonUserImage.layer.borderWidth = 3.0f;
  self.buttonUserImage.layer.masksToBounds = YES;

  if (userCurrent[@"image"]) {
    
    PFFile *file = userCurrent[@"image"];
    
    __weak typeof (self) weakSelf = self;
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
      
      if (data.length > 0) {
        
        [weakSelf.buttonUserImage setBackgroundImage:[UIImage imageWithData:data]
                                            forState:UIControlStateNormal];
      }
    }];
    
  }
  else{
    
  }
  
  self.didEdit = NO;
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  [self fetchNumberOfMentors];
  [self fetchNumberOfFolowers];
  [self fetchNumberOfMissionsInProgress];
  [self fetchNumberOfAssignedMissions];
}

- (void)dealloc{
  
  if (self.didEdit) {
    
    PFUser *user = [PFUser currentUser];
    
    user.password = self.textFieldPassword.text;
    user[@"fullName"] = self.textFieldFullName.text;
    user[@"title"] = self.textFieldTitle.text;
    
    if (self.imageChanged) {
      
      UIImage *image = [self.buttonUserImage backgroundImageForState:self.buttonUserImage.state];
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

#pragma mark - Networking

- (void)fetchNumberOfMentors{

  __weak typeof (self) weakSelf = self;
  
  PFQuery *query = [PFQuery mentors];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
    
    weakSelf.labelMentorsCount.text = [NSString stringWithFormat:@"%d",number];
  }];
}

- (void)fetchNumberOfFolowers{
  
  __weak typeof (self) weakSelf = self;
  
  PFQuery *query = [PFQuery followers];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
    
    weakSelf.labelFollowersCount.text = [NSString stringWithFormat:@"%d",number];
  }];
}

- (void)fetchNumberOfMissionsInProgress{
  
  __weak typeof (self) weakSelf = self;
  
  PFQuery *query = [PFQuery queryWithClassName:@"Mission"];
  [query whereKey:@"usersAsignees" equalTo:[PFUser currentUser]];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
    
    weakSelf.labelMissionsAssignedCount.text = [NSString stringWithFormat:@"%d",number];
  }];
}

- (void)fetchNumberOfAssignedMissions{
  
  __weak typeof (self) weakSelf = self;
  
  PFQuery *query = [PFQuery queryWithClassName:@"Mission"];
  [query whereKey:@"userReporter" equalTo:[PFUser currentUser]];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
    
    weakSelf.labelMissionsAssignedCount.text = [NSString stringWithFormat:@"%d",number];
  }];
}

#pragma mark - Action Handling

- (IBAction)tapButtonUserImage:(id)sender{
  
#warning TODO: localizations
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Photo"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:kTitleButtonImageSourceCameraRollCameraRoll4, kTitleButtonImageSourceCameraRollTakeAPicture4, nil];
  
  if (IS_IPAD) {
    
    [actionSheet showInView:self.view];
  }
  else{
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
  }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    
  }
  else {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kTitleButtonImageSourceCameraRollTakeAPicture4]) {
      
      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if ([buttonTitle isEqualToString:kTitleButtonImageSourceCameraRollCameraRoll4]){
      
      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:NULL];
  }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
  
  self.imageChanged = YES;
  self.didEdit = YES;
  
  UIImage *image = info[UIImagePickerControllerOriginalImage];
  
  [self.buttonUserImage setBackgroundImage:image forState:UIControlStateNormal];
  
  [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  
  if (textField == self.textFieldTitle) {
    
    [self.textFieldFullName becomeFirstResponder];
  }
  else
    if (textField == self.textFieldFullName) {
      
        [self.textFieldPassword	becomeFirstResponder];
    }
    else
      if (textField == self.textFieldPassword){
        
        [self.textFieldPasswordRetype becomeFirstResponder];
      }
      else
        if (textField == self.textFieldPasswordRetype){
        
          [self slideViewToOrigin];
        }
  
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
  
  self.didEdit = YES;
  
  return YES;
}

@end
