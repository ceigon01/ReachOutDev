//
//  CEILoginViewController.m
//  ReachOut
//
//  Created by Jason Smith on 21.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEILoginViewController.h"
#import <Parse/Parse.h>
#import "CEISession.h"
#import "CEIAlertView.h"
#import "KLCPopup.h"
#import "CEIForgotPasswordView.h"
#import "MBProgressHUD.h"

static NSString *const kNibNameCEIForgotPasswordView = @"CEIForgotPasswordView";

@interface CEILoginViewController () <UITextFieldDelegate, CEIForgotPasswordViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UITextField *textFieldUsername;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonLogin;
@property (nonatomic, weak) IBOutlet UIButton *buttonForgotPassword;

@property (nonatomic, strong) NSString *verifyCode;

@end

@implementation CEILoginViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
  self.slideToOriginAfterTap = YES;
}


#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
  
  if (textField == self.textFieldUsername) {
    
    [self.textFieldPassword becomeFirstResponder];
  }
  else {
    
    [textField resignFirstResponder];
    [self tapButtonLogin:self.buttonLogin];
  }
  
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
  
  //intentionaly left blank
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

  //intentionaly left blank
}

#pragma mark - Action handling

- (IBAction)tapButtonBack:(id)sender{
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapButtonLogin:(id)sender{
  
  if (self.textFieldUsername.text.length == 0 ||
      self.textFieldPassword.text.length == 0) {

    [CEIAlertView showAlertViewWithValidationMessage:@"Oops! Your phone number or password was left blank"];
    return;
  }
  
  [CEISession loginUserInView:self.view
                     username:self.textFieldUsername.text
                     password:self.textFieldPassword.text
        withCompletionHandler:^{

          [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
                 errorHandler:^(NSError *error) {

                   [CEIAlertView showAlertViewWithError:error];
                 }];
}

- (IBAction)tapButtonForgotPassword:(id)paramSender{
  
  if (self.textFieldUsername.text.length < 1) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"In order to reset password, put your mobile number"];
    return;
  }
  
  MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressHUD.labelText = @"Sending SMS...";
  
  __weak typeof (self) weakSelf = self;
  
  [PFCloud callFunctionInBackground:@"passwordReset"
                     withParameters:@{
                                      @"mobileNumber" : self.textFieldUsername.text
                                      }
                              block:^(NSDictionary *results, NSError *error) {
                                
                                [progressHUD hide:YES];
                                
                                if (error) {
                                  
                                  [CEIAlertView showAlertViewWithError:error];
                                }
                                else{
                                  
                                  weakSelf.verifyCode = [results objectForKey:@"validationCode"];
                                 
                                  NSLog(@"%@",weakSelf.verifyCode);
                                  
                                  CEIForgotPasswordView *forgotPasswordView = [[[NSBundle mainBundle] loadNibNamed:kNibNameCEIForgotPasswordView
                                                                                                             owner:weakSelf
                                                                                                           options:nil]
                                                                               objectAtIndex:0];
                                  forgotPasswordView.delegate = weakSelf;
                                  
                                  KLCPopup *popup = [KLCPopup popupWithContentView:forgotPasswordView
                                                                          showType:KLCPopupShowTypeBounceInFromTop
                                                                       dismissType:KLCPopupDismissTypeSlideOutToBottom
                                                                          maskType:KLCPopupMaskTypeDimmed
                                                          dismissOnBackgroundTouch:NO
                                                             dismissOnContentTouch:NO];
                                  
                                  [popup showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                                                           KLCPopupVerticalLayoutTop)];
                                  
                                  [forgotPasswordView.textFieldCode becomeFirstResponder];
                                }
                              }];
}

#pragma mark - CEIForgotPasswordView Delegate

- (void)forgotPasswordViewDidTapCancel:(CEIForgotPasswordView *)paramForgotPasswordView{
  
  [KLCPopup dismissAllPopups];
}

- (void)forgotPasswordViewDidTapDone:(CEIForgotPasswordView *)paramForgotPasswordView{
  
  if (![paramForgotPasswordView.textFieldCode.text isEqualToString:self.verifyCode]) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Wrong verification code"];
    return;
  }
  
  if (paramForgotPasswordView.textFieldPassword.text.length < 1) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Please put a password"];
    return;
  }
  
  if (![paramForgotPasswordView.textFieldPassword.text isEqualToString:paramForgotPasswordView.textFieldPasswordRetype.text]) {
    
    [CEIAlertView showAlertViewWithValidationMessage:@"Passwords do not match"];
    return;
  }
  
  MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressHUD.labelText = @"Changing password...";
  
  
  [PFCloud callFunctionInBackground:@"changePassword"
                     withParameters:@{
                                      @"password" : paramForgotPasswordView.textFieldPassword.text
                                      }
                              block:^(NSDictionary *results, NSError *error) {
                                
                                [progressHUD hide:YES];
                                
                                if (error) {
                                  
                                  [CEIAlertView showAlertViewWithError:error];
                                }
                                else{
                                  
                                  [KLCPopup dismissAllPopups];
                                }
                              }];
}

@end
