//
//  ePOSSkinManager.m
//  ePOS
//
//  Created by komatsu on 2014/06/13.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSkinManager.h"
#import "ePOSSkinBase.h"
#import "ePOSSkinBlack.h"
#import "ePOSSkinPink.h"
#import "ePOSSkinOrange.h"
#import "ePOSSkinPurple.h"
#import "ePOSUserDefault.h"

NSString * const ePOSChangeSkinNotification = @"ePOSChangeSkinNotification";

@implementation ePOSSkinManager
{
    NSDictionary *_keyboardTitles;
    ePOSSkinBase *_currentSkin;
}

static ePOSSkinManager *_manager = nil;

+ (ePOSSkinManager *)sharedSkinManager
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _manager = [[ePOSSkinManager alloc] init];
    });
    return _manager;
    
}

- (NSString *)keyboardTitleFromTag:(NSInteger)tag
{
    static dispatch_once_t onceTokenKeyboardTitle = 0;
    dispatch_once(&onceTokenKeyboardTitle, ^{
        _keyboardTitles = @{@(0)        : @"0",
                            @(1)        : @"1",
                            @(2)        : @"2",
                            @(3)        : @"3",
                            @(4)        : @"4",
                            @(5)        : @"5",
                            @(6)        : @"6",
                            @(7)        : @"7",
                            @(8)        : @"8",
                            @(9)        : @"9",
                            @(10)       : @"00",
                            @(11)       : @".",
                            @(12)       : @"↵",
                            @(13)       : @"-",
                            @(14)       : @"+",
                            @(15)       : @"C",
                            @(20)       : @"Cash",
                            @(21)       : @"Card",
                            @(22)       : @"Check"};
    });
    return _keyboardTitles[@(tag)];
}

- (void)setSkinType:(ePOSSkinType)skinType
{
    _skinType = skinType;
    if(skinType == ePOSSkinTypeBlack) {
        _currentSkin = [[ePOSSkinBlack alloc] init];
    } else if(skinType == ePOSSkinTypePink) {
        _currentSkin = [[ePOSSkinPink alloc] init];
    } else if(skinType == ePOSSkinTypeOrange) {
        _currentSkin = [[ePOSSkinOrange alloc] init];
    } else if(skinType == ePOSSkinTypePurple) {
        _currentSkin = [[ePOSSkinPurple alloc] init];
    }
}

- (UIImage *)backgroundImage;
{
    return _currentSkin.backgroundImage;
}

- (UIColor *)foregroundColor
{
    return _currentSkin.foregroundColor;
}

- (UIColor *)backgroundColor
{
    return _currentSkin.backgroundColor;
}

- (UIColor *)hilightColor
{
    return _currentSkin.hilightColor;
}

// toolbar
- (UIImage *)toolBarImage
{
    return _currentSkin.toolBarImage;
}

- (UIImage *)toolBarButtonSkin
{
    return _currentSkin.toolBarButtonSkin;
}

- (UIImage *)toolBarButtonSettings
{
    return _currentSkin.toolBarButtonSettings;
}

- (UIImage *)toolBarButtonLanguage
{
    // 言語のボタンが押されたら、トグル式にアイコンを切り替える
    if(_language == ePOSLanguageEnglish) {
        return _currentSkin.toolBarButtonLanguageJP;
    }else {
        return _currentSkin.toolBarButtonLanguageEN;
    }
}

- (UIImage *)toolBarButtonWifiON
{
    return _currentSkin.toolBarButtonWifiON;
}

- (UIImage *)toolBarButtonWifiOFF
{
    return _currentSkin.toolBarButtonWifiOFF;
}

- (UIImage *)toolBarLogoImage
{
    return _currentSkin.toolBarLogoImage;
}

- (UIImage *)toolBarPrinterImage
{
    return _currentSkin.toolBarPrinterImage;
}

- (UIImage *)toolBarDisplayImage
{
    return _currentSkin.toolBarDisplayImage;
}

- (UIImage *)toolBarKeyboardImage
{
    return _currentSkin.toolBarKeyboardImage;
}

- (UIImage *)toolBarScannerImage
{
    return _currentSkin.toolBarScannerImage;
}

- (UIActivityIndicatorViewStyle)indicatorStyle
{
    return _currentSkin.indicatorStyle;
}

// item view
- (UIImage *)itemDeleteButtonImage
{
    return _currentSkin.itemDeleteButtonImage;
}

- (UIImage *)itemTitleBarImage;
{
    return _currentSkin.itemTitleBarImage;
}
- (UIColor *)itemTitleColor
{
    return _currentSkin.itemTitleColor;
}

- (UIColor *)tableViewBacgroundColor1
{
    return _currentSkin.tableViewBacgroundColor1;
}

- (UIColor *)tableViewBacgroundColor2
{
    return _currentSkin.tableViewBacgroundColor2;
}

- (UIColor *)itemSubtotalBackgroundColor
{
    return _currentSkin.itemSubtotalBackgroundColor;
}

// draw
- (void)drawKeyboard:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name tag:(NSInteger)tag
{
    [_currentSkin drawKeyboard:context rect:rect isHighlighted:isHighlighted name:name tag:tag];
}

- (void)drawTotalBase:(CGContextRef)context rect:(CGRect)rect
{
    [_currentSkin drawTotalBase:context rect:rect];
}

- (void)drawItemDeleteButton:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name
{
    [_currentSkin drawItemDeleteButton:context rect:rect isHighlighted:isHighlighted name:name];
}

- (void)drawItemBase:(CGContextRef)context rect:(CGRect)rect
{
    [_currentSkin drawItemBase:context rect:rect];
}

#pragma mark - Private
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end

