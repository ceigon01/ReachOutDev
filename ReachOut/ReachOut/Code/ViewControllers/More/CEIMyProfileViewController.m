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

#warning TODO: redundant
NSString *const kTitleButtonImageSourceCameraRollCameraRoll4 = @"Camera roll";
NSString *const kTitleButtonImageSourceCameraRollTakeAPicture4 = @"Take a picture";

@interface CEIMyProfileViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CEIMyProfileViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  self.slideToOriginAfterTap = YES;
  self.imageChanged = NO;
  
  PFUser *userCurrent = [PFUser currentUser];
  
  self.textFieldTitle.text = userCurrent[@"title"];
  self.textFieldFullName.text = userCurrent[@"fullName"];
  self.labelPhoneNumber.text = [NSString stringWithFormat:@"+(%@) %@",userCurrent[@"phonePrefix"],userCurrent[@"mobilePhone"]];
  
  self.buttonUserImage.layer.cornerRadius = self.buttonUserImage.frame.size.width * 0.5f;
  self.buttonUserImage.layer.borderColor = [UIColor grayColor].CGColor;
  self.buttonUserImage.layer.borderWidth = 1.0f;
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
    
//    [weakSelf.buttonUserImage setImage:[UIImage imageNamed:@"sheepPhoto"] forState:UIControlStateNormal];
  }
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  [self fetchNumberOfMentors];
  [self fetchNumberOfFolowers];
  [self fetchNumberOfMissionsInProgress];
  [self fetchNumberOfAssignedMissions];
}

#pragma mark - Networking

- (void)fetchNumberOfMentors{

  __weak typeof (self) weakSelf = self;
  
  PFQuery *query = [PFUser query];
  [query whereKey:@"followers" equalTo:[PFUser currentUser]];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
    
    weakSelf.labelMentorsCount.text = [NSString stringWithFormat:@"%d",number];
  }];
}

- (void)fetchNumberOfFolowers{
  
  __weak typeof (self) weakSelf = self;
  
  PFQuery *query = [PFUser query];
  query = [[[PFUser currentUser] relationForKey:@"followers"] query];
  [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
    
    weakSelf.labelMentorsCount.text = [NSString stringWithFormat:@"%d",number];
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
  
  UIImage *image = info[UIImagePickerControllerOriginalImage];
  
  [self.buttonUserImage setBackgroundImage:image forState:UIControlStateNormal];
  
//  PFFile *imageFile = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation(image)];
//  self.user[@"image"] = imageFile;
  
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

@end
