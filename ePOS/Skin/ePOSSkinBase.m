//
//  ePOSSkinBase.m
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSkinBase.h"
#import "ePOSKeyboardViewController.h"

@implementation ePOSSkinBase

- (id)init
{
    self = [super init];
    if (self) {
        _manager = [ePOSSkinManager sharedSkinManager];
    }
    return self;
}

- (UIImage *)toolBarImage
{
    return nil;
}

- (UIImage *)keyboardNumberImage;
{
    return nil;
}

- (UIImage *)keyboardControlImage;
{
    return nil;
}

- (UIImage *)keyboardCashImage;
{
    return nil;
}

- (UIImage *)paymentImage;
{
    return nil;
}

- (UIImage *)backgroundImage;
{
    return nil;
}

- (UIColor *)foregroundColor;
{
    return [UIColor blackColor];
}

- (UIColor *)backgroundColor;
{
    return [UIColor whiteColor];
}

- (UIColor *)hilightColor
{
    return [UIColor colorWithRed:114./255. green:144./255. blue:192./255. alpha:1.];
}

- (UIColor *)tableViewBacgroundColor1;
{
    return [UIColor whiteColor];
}

- (UIColor *)tableViewBacgroundColor2;
{
    return [UIColor whiteColor];
}

-(UIImage *)toolBarButtonSkin
{
    return [UIImage imageNamed:@"skin_icon"];
}

-(UIImage *)toolBarButtonSettings
{
    return [UIImage imageNamed:@"setting_icon"];
}

-(UIImage *)toolBarButtonLanguageJP
{
    return [UIImage imageNamed:@"lang_jp_icon"];
}

-(UIImage *)toolBarButtonLanguageJPkanji
{
    return [UIImage imageNamed:@"lang_jp_kanji_icon"];
}

-(UIImage *)toolBarButtonLanguageEN
{
    return [UIImage imageNamed:@"lang_en_icon"];
}

-(UIImage *)toolBarButtonWifiON
{
    return [UIImage imageNamed:@"wifi_on_icon"];
}

-(UIImage *)toolBarButtonWifiOFF
{
    return [UIImage imageNamed:@"wifi_off_icon"];
}

- (UIImage *)toolBarLogoImage
{
    return [UIImage imageNamed:@"epson_logo"];
}

- (UIImage *)toolBarPrinterImage
{
    return [UIImage imageNamed:@"printer_icon"];
}

- (UIImage *)toolBarDisplayImage
{
    return [UIImage imageNamed:@"display_icon"];
}

- (UIImage *)toolBarKeyboardImage
{
    return [UIImage imageNamed:@"keys_icon"];
}

- (UIImage *)toolBarScannerImage
{
    return [UIImage imageNamed:@"scanner_icon"];
}

// item view
- (UIImage *)itemDeleteButtonImage
{
    return nil;
}

- (UIColor *)itemDeleteButtonTitleColor
{
    return nil;
}

- (UIImage *)itemTitleBarImage
{
    return self.toolBarImage;
}

- (UIColor *)itemTitleColor
{
    return [UIColor whiteColor];
}

- (UIColor *)itemSubtotalBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIActivityIndicatorViewStyle)indicatorStyle
{
    return UIActivityIndicatorViewStyleWhite;
}

- (void)drawKeyboard:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name tag:(NSInteger)tag;
{
}

- (void)drawHighlightKeyboard:(CGContextRef)context rect:(CGRect)rect name:(NSString *)name tag:(NSInteger)tag
{
    CGRect hRect = CGRectOffset(rect, 0., -50.);
    UIBezierPath *highPath = [UIBezierPath bezierPathWithOvalInRect:hRect];
    [[UIColor redColor] set];
    [highPath fill];

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

- (void)drawItemBase:(CGContextRef)context rect:(CGRect)rect
{
    [[self backgroundColor] set];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0., EPOS_ITEM_HEADER_POSITION_Y)];
    [linePath addLineToPoint:CGPointMake(CGRectGetWidth(rect), EPOS_ITEM_HEADER_POSITION_Y)];
    [linePath moveToPoint:CGPointMake(0., EPOS_ITEM_SUBTOTAL_POSITION_Y)];
    [linePath addLineToPoint:CGPointMake(CGRectGetWidth(rect), EPOS_ITEM_SUBTOTAL_POSITION_Y)];
    
    [linePath moveToPoint:CGPointMake(EPOS_ITEM_TABLE_ITEM_POSITION_X, 0.)];
    [linePath addLineToPoint:CGPointMake(EPOS_ITEM_TABLE_ITEM_POSITION_X, EPOS_ITEM_TABLE_POSITION_Y)];
    [linePath moveToPoint:CGPointMake(EPOS_ITEM_TABLE_PRICE_POSITION_X, 0.)];
    [linePath addLineToPoint:CGPointMake(EPOS_ITEM_TABLE_PRICE_POSITION_X, EPOS_ITEM_TABLE_POSITION_Y)];
    [linePath moveToPoint:CGPointMake(EPOS_ITEM_TABLE_QTY_POSITION_X, 0.)];
    [linePath addLineToPoint:CGPointMake(EPOS_ITEM_TABLE_QTY_POSITION_X, EPOS_ITEM_TABLE_POSITION_Y)];
    [linePath stroke];

}


// item view draw
- (void)drawItemDeleteButton:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name
{
    CGRect buttonRect = rect;//CGRectInset(rect, 2.,2.);
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:8.];
    [clipPath addClip];
    
    // background
    UIImage *image = [self itemDeleteButtonImage];
    [image drawInRect:buttonRect];
    
    if(isHighlighted) {
        CGContextSetRGBFillColor(context, 0., 0., 0., 0.5);
        CGContextFillRect(context, buttonRect);
    }
    
    // title
    if(name) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.alignment = NSTextAlignmentCenter;
        CGFloat point = 18.;
        UIFont *font = [UIFont systemFontOfSize:point];
        NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [self itemDeleteButtonTitleColor],
                                           NSFontAttributeName : font,
                                           NSParagraphStyleAttributeName: para};
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:name attributes:titleAttributes];
        CGRect textRect = rect;
        textRect.size.height = font.ascender - font.descender;
        
        textRect.origin.y = (CGRectGetHeight(rect) - point) / 2. + font.descender / 2.;
        
        [title drawInRect:textRect];
    }

}

#pragma mark - private(protect)
- (CGFloat)fontSizeFromTag:(NSInteger)tag
{
    CGFloat size = 60.;
    
    switch (tag) {
        case ePOSKeyboardKeyKindCash:
        case ePOSKeyboardKeyKindCard:
        case ePOSKeyboardKeyKindScan:
            size = 34.;
            break;
            
        default:
            size = 60.;
            break;
    }
    return size;
}

@end
