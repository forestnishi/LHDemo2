//
//  ePOSSkinGray.m
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSkinManager.h"
#import "ePOSSkinBlack.h"
#import "ePOSKeyboardViewController.h"

@implementation ePOSSkinBlack

- (UIImage *)toolBarImage
{
    return [UIImage imageNamed:@"black_blackSkin_footer"];
}

- (UIImage *)keyboardNumberImage
{
    return [UIImage imageNamed:@"black_num_button"];
}

- (UIImage *)keyboardControlImage
{
    return [UIImage imageNamed:@"black_tool_button"];
}

- (UIImage *)keyboardCashImage;
{
    return [UIImage imageNamed:@"black_payment_button"];
}

- (UIColor *)foregroundColor;
{
    return [UIColor colorWithRed:252./255 green:252./255 blue:252./255 alpha:1.];
}

- (UIColor *)backgroundColor;
{
    return [UIColor colorWithRed:180./255 green:180./255 blue:180./255 alpha:1.];
}

- (UIColor *)tableViewBacgroundColor1;
{
    return [UIColor colorWithRed:220./255. green:220./255 blue:220./255 alpha:1.];
}

- (UIColor *)tableViewBacgroundColor2;
{
    return [UIColor colorWithRed:231./255. green:231./255. blue:231./255. alpha:1.];
}

// item view
- (UIImage *)itemDeleteButtonImage
{
    return [UIImage imageNamed:@"black_del_button"];
}

- (UIColor *)itemDeleteButtonTitleColor
{
    return [UIColor colorWithRed:0./255 green:0./255 blue:0./255 alpha:1.];
}

//
- (void)drawKeyboard:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name tag:(NSInteger)tag;
{
    CGRect buttonRect = CGRectInset(rect, 2.,2.);
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:8.];
    [clipPath addClip];
    
    // background
    UIImage *image = [self keyboardImageFromTag:tag];
    [image drawInRect:buttonRect];

    if(isHighlighted) {
        CGContextSetRGBFillColor(context, 1., 1., 1., 0.5);
        CGContextFillRect(context, buttonRect);
        //[self drawHighlightKeyboard:context rect:rect name:name tag:tag];
    }
    
    // title
    if(name) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.alignment = NSTextAlignmentCenter;
        CGFloat point = [self fontSizeFromTag:tag];
        UIFont *font = [UIFont systemFontOfSize:point];
        NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                           NSFontAttributeName : font,
                                           NSParagraphStyleAttributeName: para};
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:name attributes:titleAttributes];
        CGRect textRect = rect;
        if(title.size.width > rect.size.width) {
            font = [UIFont systemFontOfSize:point * 0.8];
            NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                               NSFontAttributeName : font,
                                               NSParagraphStyleAttributeName: para};
            title = [[NSAttributedString alloc] initWithString:name attributes:titleAttributes];
        }
        textRect.size.height = font.ascender - font.descender;
        
        textRect.origin.y = (CGRectGetHeight(rect) - font.pointSize) / 2. + font.descender / 2.;
        
        [title drawInRect:textRect];
    }
}


#pragma mark - private
- (UIImage *)keyboardImageFromTag:(NSInteger)tag
{
    UIImage *image = nil;
    switch (tag) {
        case ePOSKeyboardKeyKindCash:
        case ePOSKeyboardKeyKindCard:
        case ePOSKeyboardKeyKindScan:
            image = [self keyboardCashImage];
            break;
            
        case ePOSKeyboardKeyKindEnter:
        case ePOSKeyboardKeyKindMinus:
        case ePOSKeyboardKeyKindPlus:
        case ePOSKeyboardKeyKindClear:
            image = [self keyboardControlImage];
            break;
            
        default:
            image = [self keyboardNumberImage];
            break;
    }
    return image;
}
@end
