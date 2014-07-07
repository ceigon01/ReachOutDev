//
//  NSDate+Difference.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 12.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;

@interface NSDate (Difference)

- (NSDate *)differerenceBetweenDate:(NSDate *)paramDate;
- (NSInteger)daysBetweenDate:(NSDate *)paramDate;

+ (NSInteger)totalDaysCountForTodayForMission:(PFObject *)paramMission;
+ (NSInteger)totalDaysCountForMission:(PFObject *)paramMission;

@end
