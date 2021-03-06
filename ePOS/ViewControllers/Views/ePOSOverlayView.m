//
//  ePOSOverlayView.m
//  ePOS
//
//  Created by komatsu on 2014/07/23.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSOverlayView.h"

@implementation ePOSOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
	CGContextSaveGState(c);

    CGRect guideRect = CGRectInset(rect, 50., 200.);
    
    
    CGFloat offset = 30.;
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, guideRect.origin.x, guideRect.origin.y + offset);
    CGContextAddLineToPoint(c, guideRect.origin.x, guideRect.origin.y);
    CGContextAddLineToPoint(c, CGRectGetMaxX(guideRect), guideRect.origin.y);
    CGContextAddLineToPoint(c, CGRectGetMaxX(guideRect), guideRect.origin.y + offset);

    CGContextMoveToPoint(c, guideRect.origin.x, CGRectGetMaxY(guideRect) - offset);
    CGContextAddLineToPoint(c, guideRect.origin.x, CGRectGetMaxY(guideRect));
    CGContextAddLineToPoint(c, CGRectGetMaxX(guideRect), CGRectGetMaxY(guideRect));
    CGContextAddLineToPoint(c, CGRectGetMaxX(guideRect), CGRectGetMaxY(guideRect) - offset);
    
    CGContextSetStrokeColorWithColor(c, [UIColor colorWithWhite:1. alpha:0.7].CGColor);
    CGContextSetLineWidth(c, 2.);

    CGContextStrokePath(c);

    
    CGContextRestoreGState(c);

}

@end
