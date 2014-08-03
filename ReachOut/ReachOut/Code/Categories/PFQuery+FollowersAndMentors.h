//
//  PFQuery+FollowersAndMentors.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 03.08.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFQuery (FollowersAndMentors)

+ (PFQuery *)followers;
+ (PFQuery *)mentors;

@end
