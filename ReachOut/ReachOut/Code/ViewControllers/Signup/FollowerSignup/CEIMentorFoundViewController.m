//
//  CEIMentorFoundViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIMentorFoundViewController.h"

#import <Parse/Parse.h>

@interface CEIMentorFoundViewController ()

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *labelPosition;
@property (nonatomic, weak) IBOutlet UILabel *labelFullName;
@property (nonatomic, weak) IBOutlet UIButton *buttonTryAgain;
@property (nonatomic, weak) IBOutlet UIButton *buttonContinue;

@end

@implementation CEIMentorFoundViewController

- (void)viewDidLoad{
  [super viewDidLoad];
  
  PFQuery *query = [PFUser query];
  
  [query whereKey:@"mobilePhone" equalTo:self.mentorMobileNumber];
    
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
  
    NSLog(@"%@",objects);
  }];
  
  
  
//  PFUser *user = [PFQuery getUserObjectWithId:@"xtTTysdUoM"];
//  
//  NSLog(@"%@",user);
  
}

@end
