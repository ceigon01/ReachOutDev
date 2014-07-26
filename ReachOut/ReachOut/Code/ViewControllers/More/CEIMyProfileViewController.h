//
//  CEIMyProfileViewController.h
//  ReachOut
//
//  Created by Jason Smith on 16.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"

@class PFUser;

@interface CEIMyProfileViewController : CEIBaseViewController

@property (nonatomic, weak) IBOutlet UIButton *buttonUserImage;
@property (nonatomic, weak) IBOutlet UITextField *textFieldTitle;
@property (nonatomic, weak) IBOutlet UITextField *textFieldFullName;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;
@property (nonatomic, weak) IBOutlet UILabel *labelPhoneNumber;
@property (nonatomic, weak) IBOutlet UILabel *labelMentors;
@property (nonatomic, weak) IBOutlet UILabel *labelMentorsCount;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionsInProgress;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionsInProgressCount;
@property (nonatomic, weak) IBOutlet UILabel *labelFollowers;
@property (nonatomic, weak) IBOutlet UILabel *labelFollowersCount;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionsAssigned;
@property (nonatomic, weak) IBOutlet UILabel *labelMissionsAssignedCount;

@property (nonatomic, assign) BOOL imageChanged;

@end
