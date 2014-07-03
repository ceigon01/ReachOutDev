//
//  CEIDay.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 29.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, CEIDayName){
  
  CEIDayUnknown       = -1,
  CEIDayNameMonday    = 0,
  CEIDayNameTuesday   = 1,
  CEIDayNameWednesday = 2,
  CEIDayNameThursday  = 3,
  CEIDayNameFriday    = 4,
  CEIDayNameSaturday  = 5,
  CEIDayNameSunday    = 6
};

@interface CEIDay : NSObject

+ (NSString *)dayNameWithDayNumber:(NSInteger)paramDayNumber;
+ (NSInteger *)dayNumberWithDayName:(NSString *)paramDayName;

@end
