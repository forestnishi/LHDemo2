//
//  ePOSSkinPink.m
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSkinPink.h"
#import "ePOSKeyboardViewController.h"

@implementation ePOSSkinPink
- (UIImage *)toolBarImage
{
    return [UIImage imageNamed:@"pink_footer"];
}

- (UIImage *)keyboardNumberImage
{
    return [UIImage imageNamed:@"pink_num_button"];
}

- (UIImage *)keyboardControlImage
{
    return [UIImage imageNamed:@"pink_tool_button2"];
}

- (UIImage *)keyboardCashImage;
{
    return [UIImage imageNamed:@"pink_payment_button"];
}

- (UIImage *)backgroundImage;
{
    return [UIImage imageNamed:@"pink_background"];
}

- (UIColor *)foregroundColor;
{
    return [UIColor colorWithRed:163./255 green:157./255 blue:153./255 alpha:1.];
}

- (UIColor *)backgroundColor;
{
    return [UIColor colorWithRed:180./255 green:180./255 blue:180./255 alpha:1.];
}

- (UIColor *)tableViewBacgroundColor1;
{
    return [UIColor colorWithRed:242./255. green:239./255 blue:237./255 alpha:1.];
}

- (UIColor *)tableViewBacgroundColor2;
{
    return [UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.];
}

// item view
- (UIImage *)itemDeleteButtonImage
{
    return [UIImage imageNamed:@"pink_del_button"];
}

- (UIColor *)itemDeleteButtonTitleColor
{
    return [UIColor colorWithRed:151./255 green:117./255 blue:67./255 alpha:1.];
}

// Draw
- (void)drawKeyboard:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name tag:(NSInteger)tag;
{
    CGRect buttonRect = CGRectInset(rect, 2.,2.);
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:8.];
    [clipPath addClip];
    
    // background
    UIImage *image = [self keyboardImageFromTag:tag];
    [image drawInRect:buttonRect];
    
    if(isHighlighted) {
        CGContextSetRGBFillColor(context, 0., 0., 0., 0.5);
        CGContextFillRect(context, buttonRect);
    }
    
    // title
    if(name) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.alignment = NSTextAlignmentCenter;
        CGFloat point = [self fontSizeFromTag:tag];
        UIFont *font = [UIFont systemFontOfSize:point];
        UIColor *color = [self keybordForegroundColorFromTag:tag];
        NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : color,
                                           NSFontAttributeName : font,
                                           NSParagraphStyleAttributeName: para};
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:name attributes:titleAttributes];
        CGRect textRect = rect;
        if(title.size.width > rect.size.width) {
            font = [UIFont systemFontOfSize:point * 0.8];
            NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : color,
                                               NSFontAttributeName : font,
                                               NSParagraphStyleAttributeName: para};
            title = [[NSAttributedString alloc] initWithString:name attributes:titleAttributes];
        }
        
        
        textRect.size.height = font.ascender - font.descender;
        
        textRect.origin.y = (CGRectGetHeight(rect) - font.pointSize) / 2. + font.descender / 2.;
        
        [title drawInRect:textRect];
    }
}

- (void)drawTotalBase:(CGContextRef)context rect:(CGRect)rect
{
    CGRect backRect = rect;
    backRect.size.width /= 2.;
    [[self tableViewBacgroundColor1] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:backRect];
    [path fill];
    
    backRect.origin.x = backRect.size.width;
    [[self tableViewBacgroundColor2] set];
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:backRect];
    [path1 fill];
    
    [[self backgroundColor] set];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0., CGRectGetHeight(rect) / 3.)];
    [linePath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) / 3.)];
    [linePath moveToPoint:CGPointMake(0., CGRectGetHeight(rect) / 3.  * 2.)];
    [linePath addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) / 3. * 2.)];
    [linePath moveToPoint:CGPointMake(CGRectGetMidX(rect), 0.)];
    [linePath addLineToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetHeight(rect))];
    [linePath stroke];
}

#pragma mark - private
- (UIImage *)keyboardImageFromTag:(NSInteger)tag
{
    UIImage *image = nil;
    switch (tag) {
        case ePOSKeyboardKeyKindCash:
        case ePOSKeyboardKeyKindCard:
        case ePOSKeyboardKeyKindScan:
            image = self.keyboardCashImage;
            break;
            
        case ePOSKeyboardKeyKindEnter:
        case ePOSKeyboardKeyKindMinus:
        case ePOSKeyboardKeyKindPlus:
            image = self.keyboardControlImage;
            break;
        
        case ePOSKeyboardKeyKindClear:
            image = [UIImage imageNamed:@"pink_tool_button1"];
            break;
        default:
            image = self.keyboardNumberImage;
            break;
    }
    return image;
}

- (UIColor *)keybordForegroundColorFromTag:(NSInteger)tag
{
    UIColor *color = nil;
    switch (tag) {
        case ePOSKeyboardKeyKindCash:
        case ePOSKeyboardKeyKindCard:
        case ePOSKeyboardKeyKindScan:
            color = [UIColor colorWithRed:255./255. green:255./255. blue:254./255 alpha:1.];
            break;
            
        case ePOSKeyboardKeyKindEnter:
        case ePOSKeyboardKeyKindMinus:
        case ePOSKeyboardKeyKindPlus:
        case ePOSKeyboardKeyKindClear:
            color = [UIColor colorWithRed:255./255. green:255./255. blue:254./255 alpha:1.];
            break;
            
        default:
            color = self.foregroundColor;
            break;
    }
    return color;
}

@end
