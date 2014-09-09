//
//  CEIAddCustomUserViewController.h
//  ReachOut
//
//  Created by Jason Smith on 17.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIBaseViewController.h"
#import "CEIButtonCancel.h"
#import <MessageUI/MessageUI.h>

@interface CEIAddCustomUserViewController : CEIBaseViewController <MFMessageComposeViewControllerDelegate>

@property (nonatomic, assign) BOOL isMentor;
@property (strong, nonatomic) IBOutlet CEIButtonCancel *inviteBtn;

@end
