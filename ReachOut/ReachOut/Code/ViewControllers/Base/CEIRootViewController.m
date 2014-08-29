//
//  CEIRootViewController.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIRootViewController.h"
#import "CEIColor.h"
#import <Parse/Parse.h>
#import "CEINotificationNames.h"

static NSString *const kSegueIdentifierRootSignup = @"kSegueIdentifier_Root_Signup";

@interface CEIRootViewController ()
    @property (strong,nonatomic) NSMutableArray *tabBarItems;
@end

@implementation CEIRootViewController

- (void)dealloc{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad{
	[super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleNotificationLogout:)
                                               name:kNotificationNameLogout
                                             object:nil];
  
    APP_DELEGATE.window.backgroundColor = [UIColor whiteColor];
    [[UITabBar appearance] setTintColor:[CEIColor colorPurpleText]];
    //[[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0.914 green:0.929 blue:1 alpha:1]];
    
    //Iterate through the tabs and set the on/off images
    for(UITabBarItem *tbItem in [[self tabBar] items])
    {
        [_tabBarItems addObject:tbItem];
        
        UIImage *unselectedImage = [self imageForTabBarItem:(int)[tbItem tag] selected:NO];
        UIImage *selectedImage = [self imageForTabBarItem:(int)[tbItem tag] selected:YES];
        
        [tbItem setImage: [unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [tbItem setSelectedImage: selectedImage];
        
    }
    
    
}
- (UIImage *)imageForTabBarItem:(int)tab selected:(BOOL)selected
{
    NSString *imageName;
    switch(tab)
    {
        case 0:
            imageName = [NSString stringWithFormat:@"tabFollowers%@.png", selected ? @"On":@""];
            break;
        case 1:
            imageName = [NSString stringWithFormat:@"tabMentors%@.png", selected ? @"On":@""];
            break;
        case 2:
            imageName = [NSString stringWithFormat:@"tabEncouragements%@.png", selected ? @"On":@""];
            break;
        case 3:
            imageName = [NSString stringWithFormat:@"tabMore%@.png", selected ? @"On":@""];
            break;
    }
    return [UIImage imageNamed:imageName];
}
- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
  if (![[PFUser currentUser] isAuthenticated]) {
    
  	[self performSegueWithIdentifier:kSegueIdentifierRootSignup sender:self];
  }
}

#pragma mark - Navigation

- (IBAction)unwindRegistration:(UIStoryboardSegue *)unwindSegue{
	
}

- (IBAction)unwindAddUser:(UIStoryboardSegue *)unwindSegue{

}

#pragma mark - Notification Handling

- (void)handleNotificationLogout:(NSNotification *)paramNotification{
  
  [self performSegueWithIdentifier:kSegueIdentifierRootSignup sender:self];
}

@end
