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
#import "CEIPhonePrefixPickerViewController.h"

static NSString *const kSegueIdentifierFindMentorToMentorFound = @"kSegueIdentifier_FindMentor_MentorFuond";

@interface CEIFindMentorViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubTitle;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *buttonPhonePrefix;
@property (nonatomic, weak) IBOutlet UIButton *buttonSkip;
@property (nonatomic, weak) IBOutlet UIButton *buttonFind;
@property (nonatomic, copy) NSString *phonePrefix;

@end

@implementation CEIFindMentorViewController

- (void)viewDidLoad{
	[super viewDidLoad];
	
	self.slideToOriginAfterTap = YES;
  self.phonePrefix = @"1";    //US
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
	if ([segue.identifier isEqualToString:kSegueIdentifierFindMentorToMentorFound]) {
//    
//    NSString *prefixString = [[[self.buttonPhonePrefix titleForState:self.buttonPhonePrefix.state] componentsSeparatedByCharactersInSet:
//                            [NSCharacterSet decimalDigitCharacterSet]]
//                           componentsJoinedByString:@""];
    
    ((CEIMentorFoundViewController *)segue.destinationViewController).mentorMobileNumber = self.textField.text;
    ((CEIMentorFoundViewController *)segue.destinationViewController).mentorMobileNumberPrefix = self.phonePrefix;
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

- (IBAction)unwindFindPrefix:(UIStoryboardSegue *)unwindSegue{
	
#warning TODO: there is a bug, when going back :/
  
  CEIPhonePrefixPickerViewController *pppvc = (CEIPhonePrefixPickerViewController *)unwindSegue.sourceViewController;

  if (pppvc.dictionarySelected) {
    
    NSString *countryCode = [pppvc.dictionarySelected objectForKey:@"countryShort"];
    self.phonePrefix = [pppvc.dictionarySelected objectForKey:@"code"];
    
    [self.buttonPhonePrefix setTitle:[NSString stringWithFormat:@"%@: (+%@)",countryCode,self.phonePrefix]
                            forState:UIControlStateNormal];
  }
}

#pragma mark - Action Handling

- (IBAction)tapButtonPhonePrefix:(id)paramSender{
  
}

@end
