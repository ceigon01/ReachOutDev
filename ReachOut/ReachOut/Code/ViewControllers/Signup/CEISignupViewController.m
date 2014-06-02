//
//  CEISignupViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEISignupViewController.h"

#import "CEIProfilePreviewHeaderView.h"

@interface CEISignupViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet CEIProfilePreviewHeaderView *profilePreviewHeaderView;
@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldMobileNumber;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;

@end

@implementation CEISignupViewController

#pragma mark - Action Handling

- (IBAction)tapButtonContinue:(id)sender{
	
#warning TODO: implement fields verification
	
#warning TODO: implement Twilio phone number verification
	
#warning TODO: implement functionality to count phone verifications
	
#warning TODO: implement localized strings
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mobile number verification"
																											 message:@"Please insert code that you received via text message"
																											delegate:self
																						cancelButtonTitle:@"Cancel"
																						otherButtonTitles:@"OK", nil];
	alertView.delegate = self;
	[alertView show];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex != alertView.cancelButtonIndex) {
    
#warning TODO: implement
		[self.navigationController dismissViewControllerAnimated:YES
																									completion:NULL];
	}
}

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
	
	[self slideViewToInputTextField:textField];
}

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

@end
