//
//  NSDate+Difference.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 12.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "NSDate+Difference.h"

@implementation NSDate (Difference)

- (NSDate *)differerenceBetweenDate:(NSDate *)paramDate{
  
  NSDate *fromDate;
  NSDate *toDate;
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  
  [calendar rangeOfUnit:NSDayCalendarUnit
              startDate:&fromDate
               interval:NULL
                forDate:self];
  [calendar rangeOfUnit:NSDayCalendarUnit
              startDate:&toDate
               interval:NULL
                forDate:paramDate];
  
  NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                             fromDate:fromDate
                                               toDate:toDate
                                              options:0];
  
  return [[NSCalendar currentCalendar] dateFromComponents:difference];
}

- (NSInteger)daysBetweenDate:(NSDate *)paramDate{
  
  NSDate *fromDate;
  NSDate *toDate;
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  
  [calendar rangeOfUnit:NSDayCalendarUnit
              startDate:&fromDate
               interval:NULL
                forDate:self];
  [calendar rangeOfUnit:NSDayCalendarUnit
              startDate:&toDate
               interval:NULL
                forDate:paramDate];
  
  NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                             fromDate:fromDate
                                               toDate:toDate
                                              options:0];
  
  return difference.day;
}

@end
