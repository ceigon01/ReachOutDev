//
//  CEIDay.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 29.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIDay.h"

@implementation CEIDay

+ (NSString *)dayNameWithDayNumber:(NSInteger)paramDayNumber{

#warning TODO: localizations
  
  switch (paramDayNumber) {
    case CEIDayNameMonday:    return @"Mon";
    case CEIDayNameTuesday:   return @"Tue";
    case CEIDayNameWednesday: return @"Wed";
    case CEIDayNameThursday:  return @"Thu";
    case CEIDayNameFriday:    return @"Fri";
    case CEIDayNameSaturday:  return @"Sat";
    case CEIDayNameSunday:    return @"Sun";
      
    default:
      break;
  }
  
  return @"Invalid Day";
}

+ (NSInteger)dayNumberWithDayName:(NSString *)paramDayName{

  if ([paramDayName isEqualToString:@"Mon"]) {
    
    return CEIDayNameMonday;
  }
  else
    if ([paramDayName isEqualToString:@"Tue"]) {

      return CEIDayNameTuesday;
    }
    else
      if ([paramDayName isEqualToString:@"Wed"]) {

        return CEIDayNameWednesday;
      }
      else
        if ([paramDayName isEqualToString:@"Thu"]) {
          
          return CEIDayNameThursday;
        }
        else
          if ([paramDayName isEqualToString:@"Fri"]) {

            return CEIDayNameFriday;
          }
          else
            if ([paramDayName isEqualToString:@"Sat"]) {

              return CEIDayNameSaturday;
            }
            else
              if ([paramDayName isEqualToString:@"Sun"]) {

                return CEIDayNameSunday;
              }
  
  return CEIDayUnknown;
}

@end
