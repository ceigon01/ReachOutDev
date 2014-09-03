//
//  CEIMentorSignupViewController.m
//  ReachOut
//
//  Created by Jason Smith on 04.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMentorSignupViewController.h"
#import "CEISession.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import "CEIAlertView.h"
#import "CEIPhonePrefixPickerViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+Crop.h"
#import "UIImage+ResizeMagick.h"
static const NSInteger kTagAlertViewVerificationCode1 = 12345;

#warning TODO: redundant
NSString *const kTitleButtonImageSourceCameraRollCameraRoll2 = @"Camera roll";
NSString *const kTitleButtonImageSourceCameraRollTakeAPicture2 = @"Take a picture";

@interface CEIMentorSignupViewController () <UIActionSheetDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

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
@property (nonatomic, weak) IBOutlet UILabel *labelValidMsg;
@property (nonatomic, assign) BOOL *isPhoneValid;
@property (nonatomic, assign) BOOL *isFullNameValid;
@property (nonatomic, assign) BOOL *isPasswordValid;
@property (nonatomic, assign) BOOL *isPasswordRetypeValid;
@property (nonatomic, assign) BOOL *isValid;
@property (nonatomic, strong) NSString *alertMsg;
@property (nonatomic, copy) NSString *phonePrefix;

@property (nonatomic, strong) PFUser *user;

@property (nonatomic, strong) NSString *verifyCode;

@end

@implementation CEIMentorSignupViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  [self.buttonContinue setEnabled:NO];
  [self.buttonContinue setAlpha:.5f];
  self.buttonUserImage.layer.cornerRadius = self.buttonUserImage.frame.size.width * 0.5f;
  self.buttonUserImage.layer.borderColor = [UIColor whiteColor].CGColor;
  self.buttonUserImage.layer.borderWidth = 2.0f;
  self.buttonUserImage.layer.masksToBounds = YES;
  self.isPhoneValid = NO;
  self.isFullNameValid = NO;
  self.isPasswordValid = NO;
  self.isPasswordRetypeValid = NO;
  self.isValid = NO;
  _alertMsg = @"";
    
  self.slideToOriginAfterTap = YES;
  self.phonePrefix = @"1";  //US
}

#pragma mark - Action handling

- (IBAction)tapButtonFacebook:(id)sender{
 
  __weak CEIMentorSignupViewController *weakSelf = self;
  
  [CEISession fetchFacebookDataInView:self.view
                withCompletionHandler:^(PFUser *user) {
                  
                  weakSelf.user = user;
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


- (void)sendSMS{
  
  MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressHud.labelText = @"Sending an SMS...";
  
  __weak typeof (self) weakSelf = self;
  
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:self.textFieldMobileNumber.text
                                                                   forKey:@"number"];
  [PFCloud callFunctionInBackground:@"phoneVerification1" withParameters:params
                              block:^(NSDictionary *results, NSError *error) {
                                
                                [progressHud hide:YES];
                                
                                if (error) {
                                  
                                  [CEIAlertView showAlertViewWithError:error];
                                }
                                else{
                                  
                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SMS sent!"
                                                                                      message:@"We sent you an access code to your mobile phone. Enter it below:"
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"Cancel"
                                                                            otherButtonTitles:@"OK", nil];
                                  alertView.tag = kTagAlertViewVerificationCode1;
                                  alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                                  [alertView show];
                                  
                                  weakSelf.verifyCode = [results objectForKey:@"validationCode"];
                                  NSLog(@"results: %@ %@",[results class], results);
                                }
                              }];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
  if (buttonIndex != alertView.cancelButtonIndex) {
    if (alertView.tag == kTagAlertViewVerificationCode1) {
      
      NSString *codeEntered = [[alertView textFieldAtIndex:0] text];
      
      if ([codeEntered isEqualToString:self.verifyCode] && self.verifyCode) {
        
        [self validateAndSave];
      }
    }
  }
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
    if(self.isValid){
        [self sendSMS];
    }
}

- (void)validateAndSave{
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
            
            self.user.username = self.textFieldMobileNumber.text;
            self.user.password = self.textFieldPassword.text;
            self.user[@"fullName"] = self.textFieldFullName.text;
            self.user[@"title"] = self.textFieldTitle.text;
            self.user[@"mobilePhone"] = self.textFieldMobileNumber.text;
            
            NSString *prefix = [[[self.buttonMoblieNumberPrefix titleForState:self.buttonMoblieNumberPrefix.state] componentsSeparatedByCharactersInSet:
                                 [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                componentsJoinedByString:@""];
            self.user[@"phonePrefix"] = prefix;
            
            self.user[@"mobilePhoneWithPrefix"] = [NSString stringWithFormat:@"%@%@",prefix,self.user[@"mobilePhone"]];
            
            __weak CEIMentorSignupViewController *weakSelf = self;
            [CEISession signupUser:self.user
                            inView:self.view
             withCompletionHandler:^{
               
#warning TODO: implement phone verification
               [weakSelf dismissViewControllerAnimated:YES completion:NULL];
               
               [weakSelf.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 
                 NSLog(@"double save, no idea why");
               }];
             }
                      errorHandler:^(NSError *error) {
                        
                        [CEIAlertView showAlertViewWithError:error];
                      }];
          }
}

#pragma mark - UITextField delegate
- (IBAction)textDidChange:(UITextField*)textField {
    int textLength = [textField.text length];
    if (textField == self.textFieldMobileNumber && textLength < 10){
        [self.buttonContinue setEnabled:NO];
        [self.buttonContinue setAlpha:.5f];
        self.isPhoneValid = NO;
        textField.layer.borderColor = [UIColor redColor].CGColor;
        textField.layer.borderWidth = 1.0f;
        textField.layer.cornerRadius=5.5f;
        textField.layer.masksToBounds=YES;
    }else if(textField == self.textFieldMobileNumber){
        self.isPhoneValid = YES;
        self.labelValidMsg.alpha = 0.0f;
        textField.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    if(textField == self.textFieldFullName && textLength < 2){
        [self.buttonContinue setEnabled:NO];
        [self.buttonContinue setAlpha:.5f];
        self.isFullNameValid = NO;
        textField.layer.borderColor = [UIColor redColor].CGColor;
        textField.layer.borderWidth = 1.0f;
        textField.layer.cornerRadius=5.5f;
        textField.layer.masksToBounds=YES;
    }else if(textField == self.textFieldFullName){
        self.isFullNameValid = YES;
        self.labelValidMsg.alpha = 0.0f;
        textField.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    if(textField == self.textFieldPassword  && textLength <= 5){
        [self.buttonContinue setEnabled:NO];
        [self.buttonContinue setAlpha:.5f];
        self.isPasswordValid = NO;
        textField.layer.borderColor = [UIColor redColor].CGColor;
        textField.layer.borderWidth = 1.0f;
        textField.layer.cornerRadius=5.5f;
        textField.layer.masksToBounds=YES;
    }else if(textField == self.textFieldPassword){
        self.isPasswordValid = YES;
        self.labelValidMsg.alpha = 0.0f;
        textField.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    if(textField == self.textFieldPasswordRetype && ![textField.text isEqualToString:self.textFieldPassword.text]){
        [self.buttonContinue setEnabled:NO];
        [self.buttonContinue setAlpha:.5f];
        self.isPasswordRetypeValid = NO;
        textField.layer.borderColor = [UIColor redColor].CGColor;
        textField.layer.borderWidth = 1.0f;
        textField.layer.cornerRadius=5.5f;
        textField.layer.masksToBounds=YES;
    }else if(textField == self.textFieldPasswordRetype){
        self.isPasswordRetypeValid = YES;
        textField.layer.borderColor = [[UIColor clearColor]CGColor];
        textField.layer.borderWidth = 1.0f;
    }
    
    if(self.isPhoneValid && self.isFullNameValid && self.isPasswordValid && self.isPasswordRetypeValid){
        [self.buttonContinue setEnabled:YES];
        [self.buttonContinue setAlpha:1.0f];
        self.labelValidMsg.alpha = 0.0f;
        self.isValid = YES;
    }
}
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
\
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
  
  UIImage* resizedImage = [info[UIImagePickerControllerOriginalImage] resizedImageByMagick: @"150x150#"];
  
  //[self.buttonUserImage setBackgroundImage:image forState:UIControlStateNormal];

  PFFile *imageFile = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation(resizedImage)];
  [self.buttonUserImage setBackgroundImage:resizedImage forState:UIControlStateNormal];
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
