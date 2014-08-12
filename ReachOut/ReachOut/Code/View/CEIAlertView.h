//
//  CEIAlertView.h
//  ReachOut
//
//  Created by Jason Smith on 06.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEIAlertView : UIAlertView

+ (void)showAlertViewWithValidationMessage:(NSString *)paramValidationMessage;
+ (void)showAlertViewWithError:(NSError *)paramError;
+ (void)showAlertViewCantRelateToSelfWithDelegate:(id<UIAlertViewDelegate>)paramDelegate;

@end
