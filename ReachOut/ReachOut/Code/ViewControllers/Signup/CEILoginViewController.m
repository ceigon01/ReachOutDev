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

@interface CEILoginViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UITextField *textFieldUsername;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UIButton *buttonLogin;

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

@end
