//
//  UIView+NibLoading.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "UIView+NibLoading.h"

const NSUInteger kNibReferencingTag = 687;

@implementation UIView (NibLoading)

+ (id)loadInstanceFromNib{
	
  UIView *result = nil;
  NSArray *elements = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
	
  for (id anObject in elements) {
		
    if ([anObject isKindOfClass:[self class]]) {

      result = anObject;
      break;
    }
  }
  return result;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder{
	
  if (self.tag == kNibReferencingTag) {
		
    //! placeholder
    UIView *realView = [[self class] loadInstanceFromNib];
    realView.frame = self.frame;
    realView.alpha = self.alpha;
    realView.backgroundColor = self.backgroundColor;
    realView.autoresizingMask = self.autoresizingMask;
    realView.autoresizesSubviews = self.autoresizesSubviews;
    
    for (UIView *view in self.subviews) {
			
      [realView addSubview:view];
    }
    return realView;
  }
	
  return [super awakeAfterUsingCoder:aDecoder];
}

@end
