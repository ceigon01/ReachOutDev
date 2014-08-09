//
//  CEISession.m
//  ReachOut
//
//  Created by Jason Smith on 06.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEISession.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"

@implementation CEISession

+ (void)fetchFacebookDataInView:(UIView *)paramView
          withCompletionHandler:(void (^)(PFUser *user))paramCompletionHandler
                   errorHandler:(void (^)(NSError *error))paramErrorHandler{
  
  __block MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:paramView animated:YES];
  progressHud.labelText = @"Initializing Facebook...";
  
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

                                  [progressHud hide:YES];
                                  
                                  PFUser *user = [PFUser currentUser];
                                  if (user == nil) {

                                    user = [PFUser user];
                                  }
                                  
                                  user[@"fullName"] = [NSString stringWithFormat:@"%@ %@",[userData objectForKey:@"first_name"],[userData objectForKey:@"last_name"]];
                                  NSString *imageURLString = [[[userData objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                                  
                                  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]];
                                  
                                  user[@"facebookSignin"] = @YES;
                                  user[@"image"] = [PFFile fileWithData:data];
                                  
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
  
  if ([paramUser[@"facebookSignin"] boolValue]) {
    
//    PFACL *roleACL = [PFACL ACL];
//    [roleACL setPublicReadAccess:YES];
//    PFRole *role = [PFRole roleWithName:[paramUser[@"isMentor"] boolValue] ? @"Mentor" : @"Follower"
//                                    acl:roleACL];
//    [role saveInBackground];
//    [role.users addObject:[PFUser currentUser]];
//    [role saveInBackground];
    
    PFInstallation *instalation = [PFInstallation currentInstallation];
    instalation[@"user"] = paramUser;
    [instalation save];
    PFRelation *relation = paramUser[@"installations"];
    [relation addObject:instalation];
    [paramUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

      [progressHud hide:YES];
      if (error) {
        
        paramErrorHandler(error);
      }
      else{
        
        paramCompletionHandler();
      }

      
    }];
  }
  else{
  
    [paramUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
        if (error) {
          
          [progressHud hide:YES];
          paramErrorHandler(error);
        }
        else{
          
//          PFACL *roleACL = [PFACL ACL];
//          [roleACL setPublicReadAccess:YES];
//          PFRole *role = [PFRole roleWithName:[paramUser[@"isMentor"] boolValue] ? @"Mentor" : @"Follower"
//                                          acl:roleACL];
//          [role saveInBackground];
//          [role.users addObject:[PFUser currentUser]];
//          [role saveInBackground];
          
          PFInstallation *instalation = [PFInstallation currentInstallation];
          instalation[@"user"] = paramUser;
          [instalation save];
          PFRelation *relation = paramUser[@"installations"];
          [relation addObject:instalation];
          [paramUser save];
          
          [progressHud hide:YES];
          paramCompletionHandler();
        }
    }];
  }
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
      
      PFInstallation *instalation = [PFInstallation currentInstallation];
      instalation[@"user"] = user;
      [instalation save];
      PFRelation *relation = user[@"installations"];
      [relation addObject:instalation];
      [user save];
      
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
