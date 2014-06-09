//
//  CEIFindMentorViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIFindMentorViewController.h"
#import "CEIMentorFoundViewController.h"
#import "CEIAlertView.h"

static NSString *const kSegueIdentifierFindMentorToMentorFound = @"kSegueIdentifier_FindMentor_MentorFuond";

@interface CEIFindMentorViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubTitle;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *buttonSkip;
@property (nonatomic, weak) IBOutlet UIButton *buttonFind;

@end

@implementation CEIFindMentorViewController

- (void)viewDidLoad{
	[super viewDidLoad];
	
#warning TODO: debug
  self.textField.text = @"8015439423";
  
	self.slideToOriginAfterTap = YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
	if ([segue.identifier isEqualToString:kSegueIdentifierFindMentorToMentorFound]) {
    
    ((CEIMentorFoundViewController *)segue.destinationViewController).mentorMobileNumber = self.textField.text;
  }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
	
	if ([identifier isEqualToString:kSegueIdentifierFindMentorToMentorFound]) {
    
#warning TODO: implement more complex phone text field verification
    if (self.textField.text.length == 0) {

      [CEIAlertView showAlertViewWithValidationMessage:@"Please insert your mentors the phone number"];
      return NO;
    }
	}
	
	return YES;
}

- (IBAction)unwindFindMentor:(UIStoryboardSegue *)unwindSegue{
	
}

#pragma mark - UITextField delegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
	
	[self slideViewToOrigin];
}

@end
