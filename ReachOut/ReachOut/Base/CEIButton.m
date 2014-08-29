//
//  CEIButton.m
//  ReachOut
//
//  Created by Jason Smith on 8/28/14.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIButton.h"
#import "CEIColor.h"

@interface CEIButton ()

@property (strong,nonatomic) CAGradientLayer *backgroundLayer, *highlightBackgroundLayer;
@property (strong,nonatomic) CALayer *innerGlow;

@end


@implementation CEIButton

#pragma mark - UIButton Overrides

+ (CEIButton *)buttonWithType:(UIButtonType)type{
    return [super buttonWithType:UIButtonTypeCustom];
}

- (id)initWithCoder:(NSCoder *)coder{
    // Call the parent implementation of initWithCoder
	self = [super initWithCoder:coder];
    
    // Custom drawing methods
	if (self)
    {
		[self drawButton];
        [self drawInnerGlow];
        [self drawBackgroundLayer];
        [self drawHighlightBackgroundLayer];
		
		_highlightBackgroundLayer.hidden = YES;
	}
    
	return self;
}
- (id)initWithFrame:(CGRect)frame{
    // Call the parent implementation of initWithCoder
	self = [super initWithFrame:frame];
    
    // Custom drawing methods
	if (self)
    {
		[self drawButton];
        [self drawInnerGlow];
        [self drawBackgroundLayer];
        [self drawHighlightBackgroundLayer];
		
		_highlightBackgroundLayer.hidden = YES;
	}
    
	return self;
}
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
    [self setTitleColor:[CEIColor whiteColor] forState:UIControlStateNormal];
}

- (void)drawBackgroundLayer{
    // Check if the property has been set already
    if (!_backgroundLayer){
        // Instantiate the gradient layer
        _backgroundLayer = [CAGradientLayer layer];
        
        // Set the colors
        _backgroundLayer.colors = (@[
                                     (id)[CEIColor colorPurpleText].CGColor,
                                     (id)[CEIColor colorPurpleText].CGColor
                                     
                                     
                                     ]);
        
        // Set the stops
        _backgroundLayer.locations = (@[
                                        @0.0f,
                                        @1.0f
                                        ]);
        
        // Add the gradient to the layer hierarchy
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
        
        
        
    }
}

- (void)drawHighlightBackgroundLayer
{
    if (!_highlightBackgroundLayer)
    {
        _highlightBackgroundLayer = [CAGradientLayer layer];
        _highlightBackgroundLayer.colors = (@[
                                              (id)[CEIColor colorPurpleText].CGColor,
                                              (id)[CEIColor colorPurpleText].CGColor
                                              ]);
        _highlightBackgroundLayer.locations = (@[
                                                 @0.0f,
                                                 @1.0f
                                                 ]);
        [self.layer insertSublayer:_highlightBackgroundLayer atIndex:1];
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


