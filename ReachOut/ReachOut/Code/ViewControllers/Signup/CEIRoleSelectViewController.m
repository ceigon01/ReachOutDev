//
//  CEIRoleSelectViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIRoleSelectViewController.h"
#import "CEIMentorSignupViewController.h"

static NSString *const kIdentifierSegueRoleSelectToMotto = @"kIdentifierSegueRoleSelectToMotto";
static NSString *const kUserDefaultsKeyDidShowMottoViewController = @"kUserDefaultsKeyDidShowMottoViewController";

@interface CEIRoleSelectViewController ()

@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UILabel *labelSubTitle;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *buttonYes;
@property (nonatomic, weak) IBOutlet UIButton *buttonNo;

@end

@implementation CEIRoleSelectViewController

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if (![userDefaults boolForKey:kUserDefaultsKeyDidShowMottoViewController]) {
    
    [self performSegueWithIdentifier:kIdentifierSegueRoleSelectToMotto sender:self];
  }
}

#pragma mark - Navigation

- (IBAction)unwindMotto:(UIStoryboardSegue *)unwindSegue{
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setBool:YES forKey:kUserDefaultsKeyDidShowMottoViewController];
}

@end
