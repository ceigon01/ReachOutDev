//
//  CEIProfilePreviewHeaderView.m
//  ReachOut
//
//  Created by Jason Smith on 31.05.2014.
//  Copyright (c) 2014 CEIGON. All rights reserved.
//

#import "CEIProfilePreviewHeaderView.h"

@implementation CEIProfilePreviewHeaderView

- (void)awakeFromNib{
	[super awakeFromNib];
	

}

- (void)drawRect:(CGRect)rect{
	[super drawRect:rect];

//	draws a single pixel width black line at the bottom of the view
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	
	CGContextSetLineWidth(context, 1.0f);
	
	CGContextMoveToPoint(context, 0.0f, rect.size.height);
	CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
	
	CGContextStrokePath(context);
}

@end
