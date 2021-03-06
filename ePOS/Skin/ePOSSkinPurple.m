//
//  ePOSSkinPurple.m
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSkinPurple.h"

@implementation ePOSSkinPurple
- (UIImage *)toolBarImage
{
    return [UIImage imageNamed:@"purple_footer"];
}

- (UIImage *)keyboardNumberImage
{
    return [UIImage imageNamed:@"purple_num_button"];
}

- (UIImage *)keyboardControlImage
{
    //return [UIImage imageNamed:@"purple_tool_button"];
    return [UIImage imageNamed:@"purple_payment_button"];
}

- (UIImage *)keyboardCashImage;
{
    return [UIImage imageNamed:@"purple_payment_button"];
}

- (UIImage *)backgroundImage;
{
    return [UIImage imageNamed:@"purple_background"];
}

- (UIColor *)foregroundColor;
{
    return [UIColor colorWithRed:92./255 green:77./255 blue:90./255 alpha:1.];
}

- (UIColor *)backgroundColor;
{
    return [UIColor colorWithRed:255./255 green:255./255 blue:255./255 alpha:1.];
}

- (UIColor *)tableViewBacgroundColor1;
{
    return [UIColor colorWithRed:208./255. green:200./255 blue:205./255 alpha:1.];
}

- (UIColor *)tableViewBacgroundColor2;
{
    return [UIColor colorWithRed:213./255. green:204./255. blue:213./255. alpha:1.];
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

// item view
- (UIImage *)itemDeleteButtonImage
{
    return [UIImage imageNamed:@"purple_del_button"];
}

- (UIColor *)itemDeleteButtonTitleColor
{
    return [UIColor colorWithRed:107./255 green:106./255 blue:106./255 alpha:1.];
}

- (UIColor *)itemSubtotalBackgroundColor
{
    return [UIColor colorWithRed:227./255 green:211./255 blue:219./255 alpha:1.];
}

- (UIActivityIndicatorViewStyle)indicatorStyle
{
    return UIActivityIndicatorViewStyleGray;
}

// draw
- (void)drawKeyboard:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name tag:(NSInteger)tag;
{
    CGRect buttonRect = rect;
    
    //UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:8.];
    //[clipPath addClip];
    
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

#pragma mark - private
- (UIImage *)keyboardImageFromTag:(NSInteger)tag
{
    UIImage *image = nil;
    switch (tag) {
        case 20:
        case 21:
        case 22:
            image = self.keyboardCashImage;
            break;
            
        case 12:
        case 13:
        case 14:
        case 15:
            image = self.keyboardControlImage;
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
        case 20:
        case 21:
        case 22:
            color = [UIColor colorWithRed:255./255. green:255./255. blue:254./255 alpha:1.];
            break;
            
        case 12:
        case 13:
        case 14:
        case 15:
            color = [UIColor colorWithRed:255./255. green:255./255. blue:254./255 alpha:1.];
            break;
            
        default:
            color = self.foregroundColor;
            break;
    }
    return color;
}

@end
