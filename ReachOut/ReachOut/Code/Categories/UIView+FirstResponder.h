//
//  UIView+FirstResponder.h
//  ReachOut
//
//  Created by Jason Smith on 01.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FirstResponder)

- (UIView *)firstResponder;
- (void)findAndResignFirstResponder;

@end
