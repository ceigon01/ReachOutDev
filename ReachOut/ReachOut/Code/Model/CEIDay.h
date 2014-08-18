//
//  CEIDay.h
//  ReachOut
//
//  Created by Jason Smith on 29.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, CEIDayName){
  
  CEIDayUnknown       = -1,
  CEIDayNameSunday    = 1,
  CEIDayNameMonday    = 2,
  CEIDayNameTuesday   = 3,
  CEIDayNameWednesday = 4,
  CEIDayNameThursday  = 5,
  CEIDayNameFriday    = 6,
  CEIDayNameSaturday  = 7,
};

@interface CEIDay : NSObject

+ (NSString *)dayNameWithDayNumber:(NSInteger)paramDayNumber;
+ (NSInteger)dayNumberWithDayName:(NSString *)paramDayName;

@end
