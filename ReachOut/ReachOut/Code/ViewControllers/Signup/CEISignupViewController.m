//
//  CEISignupViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEISignupViewController.h"

#import "CEICodeVerificationView.h"
#import "ASDepthModalViewController.h"
#import <Parse/Parse.h>
#import "CEISession.h"
#import "UIImageView+WebCache.h"
#import "CEIAlertView.h"
#import "MBProgressHUD.h"

#warning TODO: redundant
NSString *const kTitleButtonImageSourceCameraRollCameraRoll3 = @"Camera roll";
NSString *const kTitleButtonImageSourceCameraRollTakeAPicture3 = @"Take a picture";

static const NSInteger kTagAlertViewVerificationCode = 1234;

@interface CEISignupViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldMobileNumber;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;
@property (nonatomic, weak) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;
@property (nonatomic, weak) IBOutlet UIButton *buttonUserImage;

@property (nonatomic, weak) IBOutlet UIImageView *imageViewMentor;
@property (nonatomic, weak) IBOutlet UILabel *labelRelation;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;

@property (nonatomic, strong) CEICodeVerificationView *codeVerificationView;

@property (nonatomic, strong) PFUser *user;

@property (nonatomic, copy) NSString *verifyCode;

@end

@implementation CEISignupViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: add prefix field
  
  self.buttonUserImage.layer.cornerRadius = self.buttonUserImage.frame.size.width * 0.5f;
  self.buttonUserImage.layer.borderColor = [UIColor grayColor].CGColor;
  self.buttonUserImage.layer.borderWidth = 1.0f;
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
          self.user[@"fullName"] = self.textFieldFullName.text;
          
          //            NSString *prefix = [[[self.butt titleForState:self.buttonMoblieNumberPrefix.state] componentsSeparatedByCharactersInSet:
          //                                 [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
          //                                componentsJoinedByString:@""];
          //            self.user[@"phonePrefix"] = prefix;
          
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
                  
                  weakSelf.user[@"fullName"] = user[@"fullName"];
                  weakSelf.user[@"imageURL"] = user[@"imageURL"];

                  weakSelf.textFieldFullName.text = user[@"fullName"];
                  
                  PFFile *file = user[@"image"];
                  
                  [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    [weakSelf.buttonUserImage setImage:[UIImage imageWithData:data]
                                              forState:UIControlStateNormal];
                  }];
                  
                }
                         errorHandler:^(NSError *error) {
                           
                           [CEIAlertView showAlertViewWithError:error];
                         }];

}

- (IBAction)tapButtonContinue:(id)sender{
  
  [self sendSMS];
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
