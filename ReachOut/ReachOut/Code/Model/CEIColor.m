//
//  CEIColor.m
//  ReachOut
//
//  Created by Piotr Nietrzebka on 22.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIColor.h"

@implementation CEIColor

+ (UIColor *)colorRed{
  
  return [UIColor colorWithRed:225.0f / 255.0f
                         green:90.0f / 255.0f
                          blue:101.0f / 255.0f
                         alpha:1.0f];
}

+ (UIColor *)colorGreen{

  return [UIColor colorWithRed:111.0f / 255.0f
                         green:194.0f / 255.0f
                          blue:86.0f / 255.0f
                         alpha:1.0f];
}

+ (UIColor *)colorIdle{
  
  return [UIColor lightGrayColor];
}

@end
