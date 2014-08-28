//
//  CEIButtonCancel.m
//  ReachOut
//
//  Created by Jason Smith on 8/28/14.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIButtonCancel.h"
#import "CEIColor.h"

@implementation CEIButtonCancel

- (void)layoutSubviews{
    // Set inner glow frame (1pt inset)
    _innerGlow.frame = CGRectInset(self.bounds, 1, 1);
    
    // Set gradient frame (fill the whole button))
    _backgroundLayer.frame = self.bounds;
    
    // Set inverted gradient frame
    _highlightBackgroundLayer.frame = self.bounds;
	
	[super layoutSubviews];
}

- (void)setHighlighted:(BOOL)highlighted{
	// Disable implicit animation
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
    
    // Hide/show inverted gradient
	_highlightBackgroundLayer.hidden = !highlighted;
	[CATransaction commit];
	
	[super setHighlighted:highlighted];
}

#pragma mark - Layer setters

- (void)drawButton{
    // Get the root layer (any UIView subclass comes with one)
    CALayer *layer = self.layer;
    
    layer.cornerRadius = 5;
    layer.borderWidth = 1;
    layer.masksToBounds = YES;
    layer.borderColor = [CEIColor colorPurpleText].CGColor;
    [self setTitleColor:[CEIColor colorPurpleText] forState:UIControlStateNormal];
}

- (void)drawBackgroundLayer{
    // Check if the property has been set already
    if (!_backgroundLayer){
    }
}

- (void)drawHighlightBackgroundLayer
{
    if (!_highlightBackgroundLayer)
    {
    }
}

- (void)drawInnerGlow
{
    if (!_innerGlow)
    {
        // Instantiate the innerGlow layer
        _innerGlow = [CALayer layer];
        
        _innerGlow.cornerRadius= 4;
        _innerGlow.borderWidth = 1;
        _innerGlow.borderColor = [[UIColor whiteColor] CGColor];
        _innerGlow.opacity = 0.5;
        
        [self.layer insertSublayer:_innerGlow atIndex:2];
    }
}

@end
