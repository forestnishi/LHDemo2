//
//  ePOSKeyboardHighlightedView.m
//  ePOS
//
//  Created by komatsu on 2014/06/24.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSKeyboardHighlightedView.h"

@implementation ePOSKeyboardHighlightedView
{
    NSString *_title;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _title = title;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
#if 1
    
    CGRect hRect = rect;
    UIBezierPath *highPath = [UIBezierPath bezierPath];
    CGFloat radius = 12.;
    [highPath moveToPoint:CGPointMake(hRect.origin.x, hRect.origin.y + radius)];
    [highPath addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:180. * M_PI / 180. endAngle:270. * M_PI / 180. clockwise:YES];
    [highPath addLineToPoint:CGPointMake(CGRectGetWidth(hRect) - radius, hRect.origin.y)];
    [highPath addArcWithCenter:CGPointMake(CGRectGetWidth(hRect) - radius, radius) radius:radius startAngle:270. * M_PI / 180. endAngle:360. * M_PI / 180. clockwise:YES];
    [highPath addLineToPoint:CGPointMake(CGRectGetWidth(hRect), CGRectGetMidY(hRect))];
    [highPath addLineToPoint:CGPointMake(CGRectGetMidX(hRect), CGRectGetHeight(hRect))];
    [highPath addLineToPoint:CGPointMake(hRect.origin.x, CGRectGetMidY(hRect))];
    [highPath addLineToPoint:CGPointMake(hRect.origin.x, hRect.origin.x + radius)];
    
    [[UIColor redColor] set];
    [highPath fill];

    if(_title) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.alignment = NSTextAlignmentCenter;
        CGFloat point = 60.;
        UIFont *font = [UIFont systemFontOfSize:point];
        NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                           NSFontAttributeName : font,
                                           NSParagraphStyleAttributeName: para};
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:_title attributes:titleAttributes];
        CGRect textRect = rect;
        textRect.size.height = font.ascender - font.descender;
        
        textRect.origin.y = (CGRectGetHeight(rect) - point) / 2. + font.descender / 2. - rect.size.height / 10.;
        
        [title drawInRect:textRect];
    }

#else
    CGRect hRect = rect;
    UIBezierPath *highPath = [UIBezierPath bezierPathWithRoundedRect:hRect cornerRadius:12.];
    [[UIColor redColor] set];
    [highPath fill];
#endif
    CGContextRestoreGState(context);
}

@end
