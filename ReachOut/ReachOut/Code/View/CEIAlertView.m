//
//  CEIAlertView.m
//  ReachOut
//
//  Created by Jason Smith on 06.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAlertView.h"

@implementation CEIAlertView

+ (void)showAlertViewWithValidationMessage:(NSString *)paramValidationMessage{
  
#warning TODO: validate strings & localizations
  [[[UIAlertView alloc] initWithTitle:@"Validation error"
                              message:paramValidationMessage
                             delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

+ (void)showAlertViewWithError:(NSError *)paramError{

#warning TODO: validate strings & localizations
  
  NSString *errorMessage = [paramError.userInfo objectForKey:@"error"];
  
  [[[UIAlertView alloc] initWithTitle:@"Error"
                              message:errorMessage
                             delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

+ (void)showAlertViewCantRelateToSelfWithDelegate:(id<UIAlertViewDelegate>)paramDelegate{
  
#warning TODO: validate strings & localizations
  
  [[[UIAlertView alloc] initWithTitle:@"Oh snap!"
                              message:@"You are pretty cool, but we can't allow you to be your own Mentor. Wink."
                             delegate:paramDelegate
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

@end
