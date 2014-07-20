//
//  CEIAddCustomUserViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 17.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddCustomUserViewController.h"
#import "CEICustomUserFoundViewController.h"

static NSString *const kIdentifierSegueAddCustomUserToCustomUserFound = @"kIdentifierSegueAddCustomUserToCustomUserFound";

@interface CEIAddCustomUserViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation CEIAddCustomUserViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kIdentifierSegueAddCustomUserToCustomUserFound]) {

    ((CEICustomUserFoundViewController *)segue.destinationViewController).isMentor = self.isMentor;
    ((CEICustomUserFoundViewController *)segue.destinationViewController).mobileNumber = self.textField.text;
  }
}

- (IBAction)unwindCustomUserFound:(UIStoryboardSegue *)unwindSegue{
  
  
}

@end
