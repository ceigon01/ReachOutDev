//
//  PFQuery+FollowersAndMentors.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 03.08.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "PFQuery+FollowersAndMentors.h"

@implementation PFQuery (FollowersAndMentors)

+ (PFQuery *)followers{
  
  PFQuery *query1 = [PFUser query];
  [query1 whereKey:@"mentors" equalTo:[PFUser currentUser]];
  PFQuery *query2 = [[[PFUser currentUser] relationForKey:@"followers"] query];
  
  return [PFQuery orQueryWithSubqueries:@[query1,query2]];
}

+ (PFQuery *)mentors{
  
  PFQuery *query1 = [PFUser query];
  [query1 whereKey:@"followers" equalTo:[PFUser currentUser]];
  PFQuery *query2 = [[[PFUser currentUser] relationForKey:@"mentors"] query];
  
  return [PFQuery orQueryWithSubqueries:@[query1,query2]];
}

@end
