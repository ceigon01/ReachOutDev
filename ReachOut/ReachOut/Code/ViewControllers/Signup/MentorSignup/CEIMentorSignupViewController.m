//
//  CEIMentorSignupViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 04.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMentorSignupViewController.h"
#import "CEISession.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import "CEIAlertView.h"
#import "CEIPhonePrefixPickerViewController.h"

#warning TODO: redundant
NSString *const kTitleButtonImageSourceCameraRollCameraRoll2 = @"Camera roll";
NSString *const kTitleButtonImageSourceCameraRollTakeAPicture2 = @"Take a picture";

@interface CEIMentorSignupViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *buttonUserImage;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubtitle;
@property (nonatomic, weak) IBOutlet UITextField *textFieldTitle;
@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldMobileNumber;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;
@property (nonatomic, weak) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;
@property (nonatomic, weak) IBOutlet UIButton *buttonMoblieNumberPrefix;
@property (nonatomic, copy) NSString *phonePrefix;

@property (nonatomic, strong) PFUser *user;

@end

@implementation CEIMentorSignupViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  self.buttonUserImage.layer.cornerRadius = self.buttonUserImage.frame.size.width * 0.5f;
  self.buttonUserImage.layer.borderColor = [UIColor grayColor].CGColor;
  self.buttonUserImage.layer.borderWidth = 1.0f;
  self.buttonUserImage.layer.masksToBounds = YES;
  
  self.slideToOriginAfterTap = YES;
  self.phonePrefix = @"1";  //US
}

#pragma mark - Action handling

- (IBAction)tapButtonFacebook:(id)sender{
 
  __weak CEIMentorSignupViewController *weakSelf = self;
  
  [CEISession fetchFacebookDataInView:self.view
                withCompletionHandler:^(PFUser *user) {
                  
                  weakSelf.user[@"fullName"] = user[@"fullName"];
                  weakSelf.user[@"image"] = user[@"image"];
                  
                  weakSelf.textFieldFullName.text = user[@"fullName"];
                  if (weakSelf.user[@"image"]) {
                    
                    PFFile *file = self.user[@"image"];
                    
                    __weak typeof (self) weakSelf = self;
                    
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                      
                      [weakSelf.buttonUserImage setBackgroundImage:[UIImage imageWithData:data]
                                                          forState:UIControlStateNormal];
                    }];
                    
                  }
                  else{
                    
                    [weakSelf.buttonUserImage setBackgroundImage:[UIImage imageNamed:@"thumbMentor"]
                                                        forState:UIControlStateNormal];
                  }
                }
                         errorHandler:^(NSError *error) {

#warning TODO: handle error
                           NSLog(@"%@",error);
                         }];
}

#pragma mark - Navigation


- (IBAction)unwindFindPrefix:(UIStoryboardSegue *)unwindSegue{
	
#warning TODO: there is a bug, when going back :/
  
  CEIPhonePrefixPickerViewController *pppvc = (CEIPhonePrefixPickerViewController *)unwindSegue.sourceViewController;
  
  if (pppvc.dictionarySelected) {
    
    NSString *countryCode = [pppvc.dictionarySelected objectForKey:@"countryShort"];
    self.phonePrefix = [pppvc.dictionarySelected objectForKey:@"code"];
    
    [self.buttonMoblieNumberPrefix setTitle:[NSString stringWithFormat:@"%@: (+%@)",countryCode,self.phonePrefix]
                                   forState:UIControlStateNormal];
  }
}

- (IBAction)tapButtonContinue:(id)sender{
  
#warning TODO: localizations
  if (self.textFieldTitle.text.length == 0) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put your job title"];
  }
  else
    if (self.textFieldFullName.text.length == 0){
      
      [CEIAlertView showAlertViewWithValidationMessage:@"Please tell us your name"];
    }
    else
      if (self.textFieldMobileNumber.text.length == 0){
        
        [CEIAlertView showAlertViewWithValidationMessage:@"We need to verify your phone number"];
      }
      else
        if (self.textFieldPassword.text.length == 0){
          
          [CEIAlertView showAlertViewWithValidationMessage:@"You need to setup a password"];
        }
        else
          if (![self.textFieldPassword.text isEqualToString:self.textFieldPasswordRetype.text]){
    
            [CEIAlertView showAlertViewWithValidationMessage:@"Passwords do not match"];
          }
          else{
            
            self.user.username = self.user[@"mobilePhone"];
            self.user.password = self.textFieldPassword.text;
            self.user[@"fullName"] = self.textFieldFullName.text;
            self.user[@"title"] = self.textFieldTitle.text;
            self.user[@"mobilePhone"] = self.textFieldMobileNumber.text;

            NSString *prefix = [[[self.buttonMoblieNumberPrefix titleForState:self.buttonMoblieNumberPrefix.state] componentsSeparatedByCharactersInSet:
                                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                   componentsJoinedByString:@""];
            self.user[@"phonePrefix"] = prefix;
            
            self.user[@"mobilePhoneWithPrefix"] = [NSString stringWithFormat:@"%@%@",self.user[@"mobilePhone"],self.user[@"mobilePhone"]];
            
            __weak CEIMentorSignupViewController *weakSelf = self;
            [CEISession signupUser:self.user
                            inView:self.view
             withCompletionHandler:^{
             
#warning TODO: implement phone verification
               [weakSelf dismissViewControllerAnimated:YES completion:NULL];
             }
                      errorHandler:^(NSError *error) {
                      
                        [CEIAlertView showAlertViewWithError:error];
                      }];
  }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  
  if (textField == self.textFieldTitle) {
    
    [self.textFieldFullName becomeFirstResponder];
  }
  else
    if (textField == self.textFieldFullName) {
    
    [self.textFieldMobileNumber becomeFirstResponder];
  }
  else
    if (textField == self.textFieldMobileNumber){
      
      [self.textFieldPassword	becomeFirstResponder];
    }
    else if (textField == self.textFieldPassword){
      
      [self.textFieldPasswordRetype becomeFirstResponder];
    }
    else if (textField == self.textFieldPasswordRetype){
      
      [self slideViewToOrigin];
    }
  
  return YES;
}

#pragma mark - Action Handling

- (IBAction)tapButtonUserImage:(id)sender{
  
#warning TODO: localizations
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Photo"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:kTitleButtonImageSourceCameraRollCameraRoll2, kTitleButtonImageSourceCameraRollTakeAPicture2, nil];

  [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    
  }
  else {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kTitleButtonImageSourceCameraRollTakeAPicture2]) {
      
      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if ([buttonTitle isEqualToString:kTitleButtonImageSourceCameraRollCameraRoll2]){
      
      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:NULL];
  }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
  
  UIImage *image = info[UIImagePickerControllerOriginalImage];
  
  [self.buttonUserImage setBackgroundImage:image forState:UIControlStateNormal];
  
  PFFile *imageFile = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation(image)];
  
  self.user[@"image"] = imageFile;
  
  [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Lazy Getters

- (PFUser *)user{
  
  if (_user == nil) {
    
    if ([PFUser currentUser] == nil) {
      
      _user = [PFUser user];
    }
    else{

      _user = [PFUser currentUser];
    }
  }
  
  return _user;
}

@end
