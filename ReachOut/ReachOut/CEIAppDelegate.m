//
//  CEIAppDelegate.m
//  ReachOut
//
//  Created by Jason Smith on 30.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIAppDelegate.h"
#import "CEIRootViewController.h"
#import "CEIMissionViewController.h"

#import <Parse/Parse.h>

@implementation CEIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

  [Parse setApplicationId:@"uL2Rc2e46NOSjs0zhrDHbijQZnkFxEuurjloyLlA"
                clientKey:@"wwP3mr4m3p5NhU8pNZsSrxNTVCkeiE9yov7jVx8d"];
    
  [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
  
  [PFFacebookUtils initializeFacebook];
  
  [application registerForRemoteNotificationTypes:
   UIRemoteNotificationTypeBadge |
   UIRemoteNotificationTypeAlert |
   UIRemoteNotificationTypeSound];
  
  self.signupIsUp = NO;
  
	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {

  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
  [currentInstallation setDeviceTokenFromData:newDeviceToken];
  [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
  
#warning TODO: remember update the profile!
  NSLog(@"did fail to register notifications %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

  CEIRootViewController *rootViewController = (CEIRootViewController *)self.window.rootViewController;
  
  UINavigationController *navigationViewController = (UINavigationController *)rootViewController.selectedViewController;
  
  if ([[navigationViewController topViewController] isKindOfClass:[CEIMissionViewController class]]) {
    
    CEIMissionViewController *missionViewController = (CEIMissionViewController *)[navigationViewController topViewController];
    
    [missionViewController refresh];
  }
  
  [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application{}
- (void)applicationDidEnterBackground:(UIApplication *)application{}
- (void)applicationWillEnterForeground:(UIApplication *)application{}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  
  return [FBAppCall handleOpenURL:url
                sourceApplication:sourceApplication
                      withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  
  [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
- (void)applicationWillTerminate:(UIApplication *)application{}

@end
