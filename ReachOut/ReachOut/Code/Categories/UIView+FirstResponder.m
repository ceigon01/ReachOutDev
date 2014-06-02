//
//  UIView+FirstResponder.m
//  ReachOut
//
//  Created by Jason Smith on 01.06.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "UIView+FirstResponder.h"

@implementation UIView (FirstResponder)

- (UIView *)firstResponder{
	
	if (self.isFirstResponder) {
			
		return self;
	}
	
	for (UIView *subView in self.subviews) {
				
		if (subView.isFirstResponder){
			
			return subView;
		}
	}
	
	return nil;
}

- (void)findAndResignFirstResponder{
	
	[[self firstResponder] resignFirstResponder];
}

@end
