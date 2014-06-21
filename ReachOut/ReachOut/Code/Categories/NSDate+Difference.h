//
//  NSDate+Difference.h
//  ReachOut
//
//  Created by Piotr Nietrzebka on 12.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Difference)

- (NSDate *)differerenceBetweenDate:(NSDate *)paramDate;
- (NSInteger)daysBetweenDate:(NSDate *)paramDate;

@end
