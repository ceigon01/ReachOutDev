//
//  NSDate+Difference.m
//  ReachOut
//
//  Created by Jason Smith on 12.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "NSDate+Difference.h"
#import <Parse/Parse.h>

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

+ (NSInteger)totalDaysCountForTodayForMission:(PFObject *)paramMission{
  
  NSDate *dateBegins = paramMission[@"dateBegins"];
  
  NSDate *dateEnds = [NSDate date];
  
  return [dateBegins daysBetweenDate:dateEnds];
}

+ (NSInteger)totalDaysCountForMission:(PFObject *)paramMission{
  
  NSDate *dateBegins = paramMission[@"dateBegins"];
  
  if (dateBegins == nil){
    
    NSLog(@"warning! calculationg from nil date for mission: %@",paramMission);
    dateBegins = [NSDate date];
  }
  
  NSArray *arrayCountAndSeason = [paramMission[@"timeCount"] componentsSeparatedByString:@" "];
  
  if (arrayCountAndSeason.count == 1) {
    
#warning TODO: returning 1000 for neverending mission
    return 1000;
  }
  else{
  
    if (arrayCountAndSeason.count == 2){
      
      NSInteger counter = [[arrayCountAndSeason objectAtIndex:0] integerValue];
      NSString *season = [arrayCountAndSeason objectAtIndex:1];
      
      NSInteger days = 0;
      NSInteger months = 0;
      
  #warning TODO: hardcoded
      if ([season isEqualToString:@"days"]){
        
        days = counter;
      }
      else
        if ([season isEqualToString:@"months"]){
          
          months = counter;
        }
        else {
          
          return 1;
        }
      
      NSCalendar *calendar = [NSCalendar currentCalendar];
      
      NSDateComponents *dateComponentsBegins = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateBegins];
      
      dateComponentsBegins.day += days;
      dateComponentsBegins.month += months;
      
      NSDate *dateEnds = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsBegins];
      
      return [dateBegins daysBetweenDate:dateEnds];
    }
    else{
      
      return 1;
    }
  }
}

@end
