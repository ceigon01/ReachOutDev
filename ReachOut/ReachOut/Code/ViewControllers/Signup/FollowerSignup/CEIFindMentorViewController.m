//
//  CEIFindMentorViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIFindMentorViewController.h"

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
	
	self.slideToOriginAfterTap = YES;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
	
	if (identifier == kSegueIdentifierFindMentorToMentorFound) {
    
#warning TODO: implement phone text field verification
	}
	
	return YES;
}

- (IBAction)unwindMentorFound:(id)sender{
	
}

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
	
	[self slideViewToInputTextField:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	
	[self slideViewToOrigin];
}

@end
