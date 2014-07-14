//
//  CEIAppDelegate.m
//  ReachOut
//
//  Created by Jason Smith on 30.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAppDelegate.h"

#import <Parse/Parse.h>

@implementation CEIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

  [Parse setApplicationId:@"uL2Rc2e46NOSjs0zhrDHbijQZnkFxEuurjloyLlA"
                clientKey:@"wwP3mr4m3p5NhU8pNZsSrxNTVCkeiE9yov7jVx8d"];
    
  [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
  
  [application registerForRemoteNotificationTypes:
   UIRemoteNotificationTypeBadge |
   UIRemoteNotificationTypeAlert |
   UIRemoteNotificationTypeSound];
  
	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {

#warning TODO: append instalation to registered user
  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
  [currentInstallation setDeviceTokenFromData:newDeviceToken];
  [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
  
#warning TODO: remember update the profile!
  NSLog(@"did fail to register notifications %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

  [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application{}
- (void)applicationDidEnterBackground:(UIApplication *)application{}
- (void)applicationWillEnterForeground:(UIApplication *)application{}
- (void)applicationDidBecomeActive:(UIApplication *)application{}
- (void)applicationWillTerminate:(UIApplication *)application{}

@end
