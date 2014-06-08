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

@interface CEISignupViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldMobileNumber;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;
@property (nonatomic, weak) IBOutlet UIButton *buttonFacebook;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelRelation;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;

@property (nonatomic, strong) CEICodeVerificationView *codeVerificationView;

@end

@implementation CEISignupViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  self.slideToOriginAfterTap = YES;
}

#pragma mark - Action Handling

- (IBAction)tapButtonFacebook:(id)sender{
  
}

- (IBAction)tapButtonContinue:(id)sender{
	
#warning TODO: implement fields verification

  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

#warning TODO: debug data
  
  [params setObject:@"8015439423" forKey:@"number"];
  [params setObject:@"rPrpSXW6Fm8rtZyLP9EOROGxd" forKey:@"username"];
//        [params setObject:[[PFUser currentUser] username] forKey:@"username"];
//        [params setObject:self.textFieldMobileNumber.text forKey:@"number"];
        [PFCloud callFunctionInBackground:@"phoneVerification" withParameters:params block:^(id object, NSError *error) {

            if (!error) {
                
                NSLog(@"user: %@",[[PFUser currentUser] objectForKey:@"username" ]);

                ASDepthModalOptions options = ASDepthModalOptionAnimationGrow | ASDepthModalOptionBlur | ASDepthModalOptionTapOutsideToClose;
                
                [ASDepthModalViewController presentView:self.codeVerificationView
                                        backgroundColor:[UIColor whiteColor]
                                                options:options
                                      completionHandler:^{
                                         
                                          NSLog(@"complete");
                                      }];
            }
            else {
            
#warning TODO: gracefully handle error
                NSLog(@"error: %@",error);
            }
        }];

#warning TODO: implement functionality to count phone verifications
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

@end
