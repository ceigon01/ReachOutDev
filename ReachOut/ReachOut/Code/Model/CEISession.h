//
//  CEISession.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 06.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;

@interface CEISession : NSObject

+ (void)fetchFacebookDataInView:(UIView *)paramView
          withCompletionHandler:(void (^)(PFUser *user))paramCompletionHandler
                   errorHandler:(void (^)(NSError *error))paramErrorHandler;

+ (void)signupUser:(PFUser *)paramUser
            inView:(UIView *)paramView
  withCompletionHandler:(void (^)(void))paramCompletionHandler
      errorHandler:(void (^)(NSError *error))paramErrorHandler;

+ (void)loginUserInView:(UIView *)paramView
               username:(NSString *)paramUsername
               password:(NSString *)paramPassword
  withCompletionHandler:(void (^)(void))paramCompletionHandler
           errorHandler:(void (^)(NSError *error))paramErrorHandler;

+ (void)authoriseUserInView:(UIView *)paramView
      withCompletionHandler:(void (^)(void))paramCompletionHandler
               errorHandler:(void (^)(NSError *error))paramErrorHandler;

@end
