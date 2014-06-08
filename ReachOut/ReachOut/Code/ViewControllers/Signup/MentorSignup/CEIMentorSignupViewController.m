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

@interface CEIMentorSignupViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubtitle;
@property (nonatomic, weak) IBOutlet UITextField *textFieldTitle;
@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldMobileNumber;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;
@property (nonatomic, weak) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;

@property (nonatomic, strong) PFUser *user;

@end

@implementation CEIMentorSignupViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  self.slideToOriginAfterTap = YES;
}

#pragma mark - Action handling

- (IBAction)tapButtonFacebook:(id)sender{
 
  __weak CEIMentorSignupViewController *weakSelf = self;
  
  [CEISession fetchFacebookDataInView:self.view
                withCompletionHandler:^(PFUser *user) {
                  
                  weakSelf.user[@"fullName"] = user[@"fullName"];
                  weakSelf.user[@"imageURL"] = user[@"imageURL"];
                  
                  weakSelf.textFieldFullName.text = user[@"fullName"];
                  [weakSelf.imageView setImageWithURL:[NSURL URLWithString:user[@"imageURL"]]
                                     placeholderImage:[UIImage imageNamed:@"imgUserPhoto"]];
                }
                         errorHandler:^(NSError *error) {

#warning TODO: handle error
                           NSLog(@"%@",error);
                         }];
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
            
            self.user.username = self.textFieldFullName.text;
            self.user.password = self.textFieldPassword.text;
            self.user[@"mobilePhone"] = self.textFieldMobileNumber.text;
            self.user[@"isMentor"] = @YES;
            
            __weak CEIMentorSignupViewController *weakSelf = self;
            [CEISession signupUser:self.user
                            inView:self.view
             withCompletionHandler:^{
             
#warning TODO: implement phone verification
               [weakSelf dismissViewControllerAnimated:YES completion:NULL];
             }
                      errorHandler:^(NSError *error) {
                      
#warning TODO: handle error
                        NSLog(@"%@",error);
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

#pragma mark - Lazy Getters

- (PFUser *)user{
  
  if (_user == nil) {
    
    _user = [PFUser user];
  }
  
  return _user;
}

@end
