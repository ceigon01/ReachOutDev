//
//  CEIAddMentorFoundViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 03.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAddMentorFoundViewController.h"
#import <Parse/Parse.h>
#import "CEIAlertView.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"

@interface CEIAddMentorFoundViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;
@property (nonatomic, weak) IBOutlet UIButton *buttonTryAgain;
@property (nonatomic, weak) IBOutlet UIButton *buttonAdd;

@end

@implementation CEIAddMentorFoundViewController

- (void)viewDidLoad{
  [super viewDidLoad];

#warning TODO: localization
  __block MBProgressHUD *progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressView.labelText = @"Looking for your Mentor...";
  
  PFQuery *query = [PFUser query];
  [query whereKey:@"mobilePhone" equalTo:self.phoneNumber];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [progressView hide:YES];
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else
      if (objects.count == 0){
        
#warning TODO: strings
        [CEIAlertView showAlertViewWithValidationMessage:@"There are no Mentors with this mobile number"];
        
        self.labelTitle.text = @"Can't find your Mentor. :(";
        self.labelTitle.text = @"Chief Mentoring Officer";
        self.labelFullName.text = @"Mr Mentor";
      }
      else {
        
        self.userMentor = [objects lastObject];
        self.labelTitle.text = self.userMentor[@"title"];
        self.labelFullName.text = self.userMentor[@"fullName"];
        
        if (self.userMentor[@"image"]) {
          
          PFFile *file = self.userMentor[@"image"];
          
          __weak typeof (self) weakSelf = self;
          
          [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            weakSelf.imageView.image = [UIImage imageWithData:data];
            weakSelf.imageView.layer.cornerRadius = weakSelf.imageView.frame.size.height * 0.5f;
            weakSelf.imageView.layer.masksToBounds = YES;
          }];
          
        }
        else{
          
          self.imageView.image = [UIImage imageNamed:@"sheepPhoto"];
          self.imageView.layer.cornerRadius = self.imageView.frame.size.height * 0.5f;
          self.imageView.layer.masksToBounds = YES;
        }
      }
  }];
}

@end
