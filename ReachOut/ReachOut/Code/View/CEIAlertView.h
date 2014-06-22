//
//  CEIAlertView.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 06.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEIAlertView : UIAlertView

+ (void)showAlertViewWithValidationMessage:(NSString *)paramValidationMessage;
+ (void)showAlertViewWithError:(NSError *)paramError;

@end
