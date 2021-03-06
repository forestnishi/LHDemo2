//
//  ePOSSkinOrange.m
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSkinOrange.h"
#import "ePOSKeyboardViewController.h"

@implementation ePOSSkinOrange

- (UIImage *)toolBarImage
{
    return [UIImage imageNamed:@"orange_footer"];
}

-(UIImage *)toolBarButtonSkin
{
    return [UIImage imageNamed:@"skin_icon_bk"];
}

-(UIImage *)toolBarButtonSettings
{
    return [UIImage imageNamed:@"setting_icon_bk"];
}

-(UIImage *)toolBarButtonLanguageJP
{
    return [UIImage imageNamed:@"lang_jp_icon_bk"];
}

-(UIImage *)toolBarButtonLanguageJPkanji
{
    return [UIImage imageNamed:@"lang_jp_kanji_icon_bk"];
}

-(UIImage *)toolBarButtonLanguageEN
{
    return [UIImage imageNamed:@"lang_en_icon_bk"];
}

-(UIImage *)toolBarButtonWifiON
{
    return [UIImage imageNamed:@"wifi_on_icon_bk"];
}

-(UIImage *)toolBarButtonWifiOFF
{
    return [UIImage imageNamed:@"wifi_off_icon_bk"];
}

- (UIImage *)toolBarLogoImage
{
    return [UIImage imageNamed:@"epson_logo_bk"];
}

- (UIImage *)toolBarPrinterImage
{
    return [UIImage imageNamed:@"printer_icon_bk"];
}

- (UIImage *)toolBarDisplayImage
{
    return [UIImage imageNamed:@"display_icon_bk"];
}

- (UIImage *)toolBarKeyboardImage
{
    return [UIImage imageNamed:@"keys_icon_bk"];
}

- (UIImage *)toolBarScannerImage
{
    return [UIImage imageNamed:@"scanner_icon_bk"];
}


- (UIColor *)foregroundColor;
{
    return [UIColor colorWithRed:244./255 green:161./255 blue:39./255 alpha:1.];
}

- (UIActivityIndicatorViewStyle)indicatorStyle
{
    return UIActivityIndicatorViewStyleGray;
}

// item view
- (UIImage *)itemDeleteButtonImage
{
    return [UIImage imageNamed:@"black_del_button"];
}

- (UIImage *)itemTitleBarImage
{
    return nil;
}

- (UIColor *)itemTitleColor
{
    return self.foregroundColor;
}

// draw
- (void)drawKeyboard:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name tag:(NSInteger)tag;
{
    CGRect buttonRect = CGRectInset(rect, 2.,2.);
    
    if(tag < 20) {
        UIColor *forgroundColor = self.foregroundColor;
        [forgroundColor setStroke];
        if(tag >= 12) {
            [[UIColor colorWithRed:245./255. green:240./255. blue:233./255 alpha:1.] setFill];
        } else {
            [[UIColor clearColor] setFill];
        }
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:buttonRect];
        path.lineWidth = 1.;
        [path stroke];
        [path fill];
    } else {
        UIColor *forgroundColor = self.foregroundColor;
        [forgroundColor set];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:8.];
        [path fill];

    }
    // background
    if(isHighlighted) {
        if(tag < 20) {
            [[UIColor colorWithRed:0./255. green:0./255. blue:0./255 alpha:0.4] setFill];
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(buttonRect, 1, 1)];
            [path fill];
        } else {
            [[UIColor colorWithRed:0./255. green:0./255. blue:0./255 alpha:0.4] setFill];
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(buttonRect, 1, 1) cornerRadius:8.];
            [path fill];
        }
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
    CGRect backRect = CGRectInset(rect, 1., 1.);
    [[self foregroundColor] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backRect cornerRadius:12.];
    [path stroke];
        
    [[self foregroundColor] set];
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
    CGRect backRect = CGRectInset(rect, 1., 1.);
    [[self foregroundColor] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:backRect cornerRadius:12.];
    [path stroke];
    
    [[self foregroundColor] set];
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

- (void)drawItemDeleteButton:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name
{
    CGRect buttonRect = CGRectInset(rect, 2.,2.);
    
    [[self foregroundColor] set];
    UIBezierPath *back = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:8.];
    [back fill];
    
    if(isHighlighted) {
        CGContextSetRGBFillColor(context, 1., 1., 1., 0.5);
        CGContextFillRect(context, buttonRect);
    }
    
    // title
    if(name) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.alignment = NSTextAlignmentCenter;
        CGFloat point = 18.;
        UIFont *font = [UIFont systemFontOfSize:point];
        NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                           NSFontAttributeName : font,
                                           NSParagraphStyleAttributeName: para};
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:name attributes:titleAttributes];
        CGRect textRect = rect;
        textRect.size.height = font.ascender - font.descender;
        
        textRect.origin.y = (CGRectGetHeight(rect) - point) / 2. + font.descender / 2.;
        
        [title drawInRect:textRect];
    }
    
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
            
        default:
            color = self.foregroundColor;
            break;
    }
    return color;
}

@end
