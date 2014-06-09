//
//  CEIMentorFoundViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMentorFoundViewController.h"
#import "CEISignupViewController.h"
#import "CEIAlertView.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

static NSString* const kSegueIdentifierMentorFuondFollowerSignup = @"kSegueIdentifier_MentorFuond_FollowerSignup";

@interface CEIMentorFoundViewController ()

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelPosition;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;
@property (nonatomic, weak) IBOutlet UIButton *buttonTryAgain;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;

@property (nonatomic, strong) PFUser *userMentor;

@end

@implementation CEIMentorFoundViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
#warning TODO: localization
  __block MBProgressHUD *progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressView.labelText = @"Looking for your Mentor...";
  
  PFQuery *query = [PFUser query];
  [query whereKey:@"mobilePhone" equalTo:self.mentorMobileNumber];
#warning TODO: querry only the verified mentors
  //  [query whereKey:@"isVerified" equalTo:@YES];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
  
    [progressView hide:YES];
    NSLog(@"%@",objects);
    
    if (error) {
      
#warning TODO: handle error
      NSLog(@"%@",error);
    }
      else
        if (objects.count == 0){
    
#warning TODO: strings
          [CEIAlertView showAlertViewWithValidationMessage:@"There are no Mentors with this mobile number"];
          
          self.labelTitle.text = @"Can't find your Mentor. :(";
          self.labelPosition.text = @"Chief Mentoring Officer";
          self.labelFullName.text = @"Mr Mentor";
        }
        else {
          
          self.userMentor = [objects lastObject];
          self.labelPosition.text = self.userMentor[@"title"];
          self.labelFullName.text = self.userMentor[@"fullName"];
          [self.imageView setImageWithURL:[NSURL URLWithString:self.userMentor[@"imageURL"]]
                         placeholderImage:[UIImage imageNamed:@"imgUserPhoto"]];
        }
  }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
  if ([segue.identifier isEqualToString:kSegueIdentifierMentorFuondFollowerSignup]) {
    
    ((CEISignupViewController *)segue.destinationViewController).mentor = self.userMentor;
  }
}

@end
