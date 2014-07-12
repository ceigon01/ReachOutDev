//
//  CEIBaseViewController.h
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEIColor.h"

@interface CEIBaseViewController : UIViewController

@property (nonatomic, assign, getter = shouldSlideToOriginAfterTap) BOOL slideToOriginAfterTap;

- (void)slideViewToInputTextField:(UITextField *)textField;
- (void)slideViewToOrigin;

- (void)showToastWithTitle:(NSString *)paramTitle
                  subtitle:(NSString *)paramSubtitle
                   success:(BOOL)paramSuccess;

@end
