//
//  CEIForgotPasswordView.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 10.09.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CEIForgotPasswordView;

@protocol CEIForgotPasswordViewDelegate <NSObject>

- (void)forgotPasswordViewDidTapCancel:(CEIForgotPasswordView *)paramForgotPasswordView;
- (void)forgotPasswordViewDidTapDone:(CEIForgotPasswordView *)paramForgotPasswordView;

@end

@interface CEIForgotPasswordView : UIView

@property (nonatomic, weak) IBOutlet UITextField *textFieldCode;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPassword;
@property (nonatomic, weak) IBOutlet UITextField *textFieldPasswordRetype;

@property (nonatomic, weak) id<CEIForgotPasswordViewDelegate> delegate;

@end
