//
//  CEICustomUserFoundViewController.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 17.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEICustomUserFoundViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "CEIAlertView.h"
#import "CEINotificationNames.h"

@interface CEICustomUserFoundViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;
@property (nonatomic, weak) IBOutlet UIButton *buttonTryAgain;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;

@end

@implementation CEICustomUserFoundViewController

- (void)viewDidLoad{
  [super viewDidLoad];

  if (self.user) {
    
    self.labelTitle.text = self.user[@"title"];
    self.labelFullName.text = self.user[@"fullName"];
    
    if (self.user[@"image"]) {
      
      PFFile *file = self.user[@"image"];
      
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
  else{
    
  }
  
#warning TODO: localization
  __block MBProgressHUD *progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  progressView.labelText = @"Looking for your Mentor...";
  
  PFQuery *query = [PFUser query];
  [query whereKey:@"mobilePhone" equalTo:self.mobileNumber];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
    [progressView hide:YES];
    
    if (error) {
      
      [CEIAlertView showAlertViewWithError:error];
    }
    else
      if (objects.count == 0){
        
#warning TODO: strings
        [CEIAlertView showAlertViewWithValidationMessage:@"There are no ReachOut users with this mobile number"];
        
        self.labelTitle.text = @"Can't find your Mentor. :(";
        self.labelFullName.text = @"Mr Mentor";
      }
      else {
        
        self.user = [objects lastObject];
        self.labelTitle.text = self.user[@"title"];
        self.labelFullName.text = self.user[@"fullName"];
        
        if (self.user[@"image"]) {
          
          PFFile *file = self.user[@"image"];
          
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

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  
  NSString *notificationName = nil;
  PFRelation *relationTo = nil;
  PFRelation *relationFrom = nil;
  
  if (self.isMentor) {
    
    relationTo = [PFUser currentUser][@"followers"];
    relationFrom = [PFUser currentUser][@"mentors"];
    notificationName = kNotificationNameUserFollowerAdded;
    
  }
  else{
   
    relationTo = [PFUser currentUser][@"mentors"];
    relationFrom = [PFUser currentUser][@"followers"];
    notificationName = kNotificationNameUserMentorAdded;
  }
  
  [self.user saveInBackground];
  [[PFUser currentUser] saveInBackground];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                      object:self.user];
}

@end
