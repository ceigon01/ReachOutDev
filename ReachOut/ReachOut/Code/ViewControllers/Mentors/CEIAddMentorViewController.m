//
//  CEIAddMentorViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 03.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddMentorViewController.h"
#import "CEIAddMentorFoundViewController.h"

static NSString *const kIdentifierSegueAddMentorToAddMentorFound = @"kIdentifierSegueAddMentorToAddMentorFound";

@interface CEIAddMentorViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *buttonFind;

@end

@implementation CEIAddMentorViewController

- (void)viewDidLoad{
  [super viewDidLoad];

#warning TODO: debug
  self.textField.text = @"8015439423";
  
#warning TODO: localization
  self.title = @"Add a Mentor";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueAddMentorToAddMentorFound]) {
    
    CEIAddMentorFoundViewController *addMentorFoundViewController = (CEIAddMentorFoundViewController *)segue.destinationViewController;
    addMentorFoundViewController.phoneNumber = self.textField.text;
  }
}

- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender{
  
  if ([fromViewController isKindOfClass:[CEIAddMentorFoundViewController class]]) {
    
    return NO;
  }
  else
//    if ([fromViewController isKindOfClass:[CEI]]){
//    
//    }
  
  return YES;
}

@end
