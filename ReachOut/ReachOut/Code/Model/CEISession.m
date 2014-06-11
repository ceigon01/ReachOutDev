//
//  CEISession.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 06.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEISession.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@implementation CEISession

+ (void)fetchFacebookDataInView:(UIView *)paramView
          withCompletionHandler:(void (^)(PFUser *user))paramCompletionHandler
                   errorHandler:(void (^)(NSError *error))paramErrorHandler{
  
  __block MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:paramView animated:YES];
  progressHud.labelText = @"Initializing Facebook...";
  
  [PFFacebookUtils initializeFacebook];
  
  NSArray *permissions = [NSArray arrayWithObjects:@"public_profile",@"user_photos",@"email",nil];
  [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
    
    if (error) {
      
      [progressHud hide:YES];
      paramErrorHandler(error);
    }
    else
      if (!user){
        
        NSError *error = [[NSError alloc] initWithDomain:@"Uh oh. The user cancelled the Facebook login."
                                                    code:0
                                                userInfo:nil];
        [progressHud hide:YES];
        paramErrorHandler(error);
      }
      else{
        
        [FBRequestConnection startWithGraphPath:@"me"
                                     parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"id,name,first_name,last_name,email,picture",@"fields",nil]
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                NSDictionary *userData = (NSDictionary *)result;
          
                                if (error) {
            
                                  [progressHud hide:YES];
                                  paramErrorHandler(error);
                                }
                                else {

                                  PFUser *user = [PFUser user];
                                  user[@"fullName"] = [NSString stringWithFormat:@"%@ %@",[userData objectForKey:@"first_name"],[userData objectForKey:@"last_name"]];
                                  user[@"imageURL"] = [[[userData objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                                  
                                  [progressHud hide:YES];
                                  paramCompletionHandler(user);
                                }
                              }];
        }
    }];
}

+ (void)signupUser:(PFUser *)paramUser
            inView:(UIView *)paramView
withCompletionHandler:(void (^)(void))paramCompletionHandler
      errorHandler:(void (^)(NSError *error))paramErrorHandler{

  __block MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:paramView animated:YES];
  progressHud.labelText = @"Signing up...";
  
#warning TODO: should these be the same?
  paramUser[@"fullName"] = paramUser[@"username"];
  
  [paramUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
      if (error) {
        
        [progressHud hide:YES];
        paramErrorHandler(error);
      }
      else{
        
        PFACL *roleACL = [PFACL ACL];
        [roleACL setPublicReadAccess:YES];
        PFRole *role = [PFRole roleWithName:[paramUser[@"isMentor"] boolValue] ? @"Mentor" : @"Follower"
                                        acl:roleACL];
        [role saveInBackground];
        [role.users addObject:[PFUser currentUser]];
        [role saveInBackground];
        
        [progressHud hide:YES];
        paramCompletionHandler();
      }
  }];
}

+ (void)loginUserInView:(UIView *)paramView
               username:(NSString *)paramUsername
               password:(NSString *)paramPassword
  withCompletionHandler:(void (^)(void))paramCompletionHandler
           errorHandler:(void (^)(NSError *error))paramErrorHandler{
  
  __block MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:paramView animated:YES];
  progressHud.labelText = @"Logging in...";
  
  [PFUser logInWithUsernameInBackground:paramUsername
                               password:paramPassword
                                  block:^(PFUser *user, NSError *error) {
    
    if (error) {
      
      [progressHud hide:YES];
      paramErrorHandler(error);
    }
    else{
      
      [progressHud hide:YES];
      paramCompletionHandler();
    }
  }];
}

+ (void)authoriseUserInView:(UIView *)paramView
      withCompletionHandler:(void (^)(void))paramCompletionHandler
               errorHandler:(void (^)(NSError *error))paramErrorHandler{
  
}

@end