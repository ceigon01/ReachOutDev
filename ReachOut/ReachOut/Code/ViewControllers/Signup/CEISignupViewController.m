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

@interface CEISignupViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldMobileNumber;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;
@property (nonatomic, weak) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewMe;

@property (nonatomic, weak) IBOutlet UIImageView *imageViewMentor;
@property (nonatomic, weak) IBOutlet UILabel *labelRelation;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;

@property (nonatomic, strong) CEICodeVerificationView *codeVerificationView;

@property (nonatomic, strong) PFUser *user;

@end

@implementation CEISignupViewController

- (void)viewDidLoad{
  [super viewDidLoad];

#warning TODO: localizations
  self.labelRelation.text = @"Mentor";
  if (self.mentor) {
    
    self.labelTitle.text = self.mentor[@"title"];
    self.labelFullName.text = self.mentor[@"fullName"];
    [self.imageViewMentor setImageWithURL:[NSURL URLWithString:self.mentor[@"imageURL"]]
                         placeholderImage:[UIImage imageNamed:@"imgUserPhoto"]];
  }
  else {

    self.labelTitle.text = @"Sheppard";
    self.labelFullName.text = @"Mr Mentor";
  }
  
  self.slideToOriginAfterTap = YES;
}

#pragma mark - Action Handling

- (IBAction)tapButtonFacebook:(id)sender{
  
  __weak CEISignupViewController *weakSelf = self;
  
  [CEISession fetchFacebookDataInView:self.view
                withCompletionHandler:^(PFUser *user) {
                  
                  weakSelf.user[@"fullName"] = user[@"fullName"];
                  weakSelf.user[@"imageURL"] = user[@"imageURL"];

                  weakSelf.textFieldFullName.text = user[@"fullName"];
                  [weakSelf.imageViewMe setImageWithURL:[NSURL URLWithString:user[@"imageURL"]]
                                       placeholderImage:[UIImage imageNamed:@"imgUserPhoto"]];
                }
                         errorHandler:^(NSError *error) {
                           
#warning TODO: handle error
                           NSLog(@"%@",error);
                         }];

}

- (IBAction)tapButtonContinue:(id)sender{
	
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
            
            self.user.username = self.textFieldFullName.text;
            self.user.password = self.textFieldPassword.text;
            self.user[@"mobilePhone"] = self.textFieldMobileNumber.text;
            if (self.mentor.objectId) {

              self.user[@"mentorID"] = self.mentor.objectId;
            }
            self.user[@"isMentor"] = @NO;
            
            __weak CEISignupViewController *weakSelf = self;
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

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex != alertView.cancelButtonIndex) {
    
#warning TODO: implement
		[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
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

#pragma mark - Lazy Getters

- (PFUser *)user{
  
  if (_user == nil) {
    
    _user = [PFUser user];
  }
  
  return _user;
}

@end
