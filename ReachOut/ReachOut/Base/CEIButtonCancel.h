//
//  CEIButtonCancel.h
//  ReachOut
//
//  Created by Jason Smith on 8/28/14.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIButton.h"

@interface CEIButtonCancel : CEIButton
@property (strong,nonatomic) CAGradientLayer *backgroundLayer, *highlightBackgroundLayer;
@property (strong,nonatomic) CALayer *innerGlow;
@end
