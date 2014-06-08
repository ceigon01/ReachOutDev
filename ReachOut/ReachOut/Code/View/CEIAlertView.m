//
//  CEIAlertView.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 06.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAlertView.h"

@implementation CEIAlertView

+ (void)showAlertViewWithValidationMessage:(NSString *)paramValidationMessage{
  
#warning TODO: validate strings
  [[[UIAlertView alloc] initWithTitle:@"Validation error"
                              message:paramValidationMessage
                             delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

@end
