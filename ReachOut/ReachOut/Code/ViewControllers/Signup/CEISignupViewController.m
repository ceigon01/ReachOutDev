//
//  CEISignupViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEISignupViewController.h"

#import "CEICodeVerificationView.h"
#import <Parse/Parse.h>
#import "CEISession.h"
#import "UIImageView+WebCache.h"
#import "CEIAlertView.h"
#import "UIImage+Crop.h"
#import "CEIPhonePrefixPickerViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+ResizeMagick.h"

#warning TODO: redundant
NSString *const kTitleButtonImageSourceCameraRollCameraRoll3 = @"Camera roll";
NSString *const kTitleButtonImageSourceCameraRollTakeAPicture3 = @"Take a picture";

static const NSInteger kTagAlertViewVerificationCode = 1234;

@interface CEISignupViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)textDidChange:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldMobileNumber;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;
@property (nonatomic, weak) IBOutlet UIButton *buttonMoblieNumberPrefix;
@property (nonatomic, weak) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;
@property (nonatomic, weak) IBOutlet UIButton *buttonUserImage;


@property (nonatomic, weak) IBOutlet UIImageView *imageViewMentor;
@property (nonatomic, weak) IBOutlet UILabel *labelRelation;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;
@property (nonatomic, weak) IBOutlet UILabel *labelValidMsg;
@property (nonatomic, assign) BOOL *isPhoneValid;
@property (nonatomic, assign) BOOL *isFullNameValid;
@property (nonatomic, assign) BOOL *isPasswordValid;
@property (nonatomic, assign) BOOL *isPasswordRetypeValid;
@property (nonatomic, assign) BOOL *isValid;
@property (nonatomic, strong) NSString *alertMsg;
@property (nonatomic, copy) NSString *phonePrefix;

@property (nonatomic, strong) CEICodeVerificationView *codeVerificationView;

@property (nonatomic, strong) PFUser *user;

@property (nonatomic, copy) NSString *verifyCode;

@end

@implementation CEISignupViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  [self.buttonContinue setEnabled:NO];
  [self.buttonContinue setAlpha:.5f];
  self.isPhoneValid = NO;
  self.isFullNameValid = NO;
  self.isPasswordValid = NO;
  self.isPasswordRetypeValid = NO;
  self.isValid = NO;
  self.phonePrefix = @"1";  //US
  _alertMsg = @"";
#warning TODO: add prefix field
  
  self.buttonUserImage.layer.cornerRadius = self.buttonUserImage.frame.size.width * 0.5f;
  self.buttonUserImage.layer.borderColor = [UIColor whiteColor].CGColor;
  self.buttonUserImage.layer.borderWidth = 2.0f;
  self.buttonUserImage.layer.masksToBounds = YES;
  
#warning TODO: localizations
  self.labelRelation.text = @"Mentor";
  if (self.mentor) {
    
    self.labelTitle.text = self.mentor[@"title"];
    self.labelFullName.text = self.mentor[@"fullName"];

    if (self.mentor[@"image"]) {
      
      PFFile *file = self.mentor[@"image"];
      
      __weak typeof (self) weakSelf = self;
      
      [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        weakSelf.imageViewMentor.image = [UIImage imageWithData:data];
        weakSelf.imageViewMentor.layer.cornerRadius = weakSelf.imageViewMentor.frame.size.height * 0.5f;
        weakSelf.imageViewMentor.layer.masksToBounds = YES;
      }];
      
    }
    else{
      
      self.imageViewMentor.image = [UIImage imageNamed:@"sheepPhoto"];
      self.imageViewMentor.layer.cornerRadius = self.imageViewMentor.frame.size.height * 0.5f;
      self.imageViewMentor.layer.masksToBounds = YES;
    }
  }
  else {
    self.imageViewMentor.layer.cornerRadius = self.imageViewMentor.frame.size.height * 0.5f;
    self.imageViewMentor.layer.masksToBounds = YES;
    self.labelTitle.text = @"Sheppard";
    self.labelFullName.text = @"Mr Mentor";
  }
  
  self.slideToOriginAfterTap = YES;
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
                                  alertView.tag = kTagAlertViewVerificationCode;
                                  alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                                  [alertView show];

                                  weakSelf.verifyCode = [results objectForKey:@"validationCode"];
                                  NSLog(@"results: %@ %@",[results class], results);
                                }
                              }];
}

- (void)validateAndSave{
  
#warning TODO: localizations
if (self.textFieldTitle.text.length == 0) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put your job title"];
}
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
          self.user[@"mobilePhone"] = self.textFieldMobileNumber.text;
          self.user[@"title"] = self.textFieldTitle.text;
          self.user[@"fullName"] = self.textFieldFullName.text;
          
            NSString *prefix = [[[self.buttonMoblieNumberPrefix titleForState:self.buttonMoblieNumberPrefix.state] componentsSeparatedByCharactersInSet:
                                 [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                componentsJoinedByString:@""];
            self.user[@"phonePrefix"] = prefix;
            
            self.user[@"mobilePhoneWithPrefix"] = [NSString stringWithFormat:@"%@%@",prefix,self.user[@"mobilePhone"]];
          
#warning TODO: mobile number prefix
          self.user[@"mobilePhoneWithPrefix"] = [NSString stringWithFormat:@"%@%@",@"1",self.user[@"mobilePhone"]];
          
          if (self.mentor) {
            
            PFRelation *relation = [self.user relationForKey:@"mentors"];
            [relation addObject:self.mentor];
          }
          
          __weak CEISignupViewController *weakSelf = self;
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

#pragma mark - Action Handling

- (IBAction)tapButtonFacebook:(id)sender{
    
    __weak CEISignupViewController *weakSelf = self;
    
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

- (IBAction)tapButtonContinue:(id)sender{

    if(self.isValid){
        [self sendSMS];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Houstin we have a problem!"
                                                            message:_alertMsg
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
    }
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
    if (buttonIndex != alertView.cancelButtonIndex) {
      if (alertView.tag == kTagAlertViewVerificationCode) {
        
        NSString *codeEntered = [[alertView textFieldAtIndex:0] text];
        
        if ([codeEntered isEqualToString:self.verifyCode] && self.verifyCode) {
          
          [self validateAndSave];
        }
      }
      else{
        

        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
      }
  }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.textFieldTitle) {
        [self.textFieldFullName becomeFirstResponder];
    }
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

#pragma mark - Lazy Getters

- (CEICodeVerificationView *)codeVerificationView{
    
  if (_codeVerificationView == nil) {
        
      _codeVerificationView = [[[NSBundle mainBundle] loadNibNamed:@"CEICodeVerificationView"
                                                             owner:self
                                                           options:nil]
                                 objectAtIndex:1];
  }
    
  return _codeVerificationView;
}

#pragma mark - Action Handling

- (IBAction)tapButtonUserImage:(id)sender{
  
#warning TODO: localizations
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Photo"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:kTitleButtonImageSourceCameraRollCameraRoll3, kTitleButtonImageSourceCameraRollTakeAPicture3, nil];
  
  [actionSheet showInView:self.view];
}
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
#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    
  }
  else {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kTitleButtonImageSourceCameraRollTakeAPicture3]) {
      
      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if ([buttonTitle isEqualToString:kTitleButtonImageSourceCameraRollCameraRoll3]){
      
      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:NULL];
  }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
  
  UIImage* resizedImage = [info[UIImagePickerControllerOriginalImage] resizedImageByMagick: @"150x150#"];
  
  [self.buttonUserImage setBackgroundImage:resizedImage forState:UIControlStateNormal];
  
  PFFile *imageFile = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation(resizedImage)];
  
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

- (IBAction)textDidChange:(UITextField*)textField {
    int textLength = [textField.text length];
    if (textField == self.textFieldMobileNumber && textLength < 10){
        [self.buttonContinue setEnabled:NO];
        [self.buttonContinue setAlpha:.5f];
        self.isPhoneValid = NO;
        self.labelValidMsg.text = @"The phone number you entered is not valid";
        //self.labelValidMsg.alpha = 1.0f;
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
        self.labelValidMsg.text = @"Make sure you enter your full name before continuing";
        //self.labelValidMsg.alpha = 1.0f;
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
        self.labelValidMsg.text = @"Your password must greater than 5 characters long";
        //self.labelValidMsg.alpha = 1.0f;
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
        self.labelValidMsg.text = @"Oops make sure the password matches the password re-type field";
        //self.labelValidMsg.alpha = 1.0f;
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
@end
