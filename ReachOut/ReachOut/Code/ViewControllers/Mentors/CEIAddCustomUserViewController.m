//
//  CEIAddCustomUserViewController.m
//  ReachOut
//
//  Created by Jason Smith on 17.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddCustomUserViewController.h"
#import "CEICustomUserFoundViewController.h"
#import "CEIColor.h"
#import <MessageUI/MessageUI.h>
static NSString *const kIdentifierSegueAddCustomUserToCustomUserFound = @"kIdentifierSegueAddCustomUserToCustomUserFound";

@interface CEIAddCustomUserViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation CEIAddCustomUserViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
    
  [self.textField becomeFirstResponder];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueAddCustomUserToCustomUserFound]) {

    ((CEICustomUserFoundViewController *)segue.destinationViewController).isMentor = self.isMentor;
    ((CEICustomUserFoundViewController *)segue.destinationViewController).mobileNumber = self.textField.text;
  }
}
- (IBAction)inviteOthers:(id)sender {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = @"Check out ReaachOut for your smartphone. Download it today from http://blah";
		controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
	}
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
			break;
		case MessageComposeResultSent:
            
			break;
		default:
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)unwindCustomUserFound:(UIStoryboardSegue *)unwindSegue{
  
  
}

@end
