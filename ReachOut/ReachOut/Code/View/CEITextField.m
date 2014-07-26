//
//  CEITextField.m
//  ReachOut
//
//  Created by Jason Smith on 13.07.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEITextField.h"

@implementation CEITextField

- (id)initWithFrame:(CGRect)frame{
  
    self = [super initWithFrame:frame];
    if (self) {
  
      [self setup];
    }
    return self;
}

- (void)awakeFromNib{
  [super awakeFromNib];
  
  [self setup];
}

- (void)setup{
  
  UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
  self.leftViewMode = UITextFieldViewModeAlways;
  self.leftView = spacerView;
}

@end
