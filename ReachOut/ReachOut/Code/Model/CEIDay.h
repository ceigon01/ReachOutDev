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
  CEIDayNameSunday    = 0,
  CEIDayNameMonday    = 1,
  CEIDayNameTuesday   = 2,
  CEIDayNameWednesday = 3,
  CEIDayNameThursday  = 4,
  CEIDayNameFriday    = 5,
  CEIDayNameSaturday  = 6,
};

@interface CEIDay : NSObject

+ (NSString *)dayNameWithDayNumber:(NSInteger)paramDayNumber;
+ (NSInteger)dayNumberWithDayName:(NSString *)paramDayName;

@end
