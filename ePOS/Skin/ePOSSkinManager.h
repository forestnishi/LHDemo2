//
//  ePOSSkinManager.h
//  ePOS
//
//  Created by komatsu on 2014/06/13.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>

// この列挙体はePOS Epos2ModelLang と同じ値とする。違っていてはいけない。
typedef NS_ENUM(NSInteger, ePOSLanguage) {
    ePOSLanguageEnglish,
    ePOSLanguageJapanese,
};

typedef NS_ENUM(NSInteger, ePOSSkinType) {
    ePOSSkinTypeSTART,
    ePOSSkinTypeBlack = ePOSSkinTypeSTART,
    ePOSSkinTypePink,
    ePOSSkinTypeOrange,
    ePOSSkinTypePurple,
    ePOSSkinType_MAX,
    ePOSSkinTypeEND = ePOSSkinType_MAX - 1
};

typedef NS_ENUM(NSInteger, ePOSKeybordType) {
    ePOSKeybordTypeNumber,
    ePOSKeybordTypeControl,
    ePOSKeybordTypeCash,
};


extern NSString * const ePOSChangeSkinNotification;

@interface ePOSSkinManager : NSObject

@property (nonatomic) ePOSLanguage language;
@property (nonatomic) ePOSSkinType skinType;

// view
@property (nonatomic, readonly) UIImage *backgroundImage;
@property (nonatomic, readonly) UIColor *foregroundColor;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UIColor *hilightColor;

// toolbar
@property (nonatomic, readonly) UIImage *toolBarImage;
@property (nonatomic, readonly) UIImage *toolBarButtonSkin;
@property (nonatomic, readonly) UIImage *toolBarButtonSettings;
@property (nonatomic, readonly) UIImage *toolBarButtonLanguage;
@property (nonatomic, readonly) UIImage *toolBarButtonWifiON;
@property (nonatomic, readonly) UIImage *toolBarButtonWifiOFF;
@property (nonatomic, readonly) UIImage *toolBarLogoImage;
@property (nonatomic, readonly) UIImage *toolBarPrinterImage;
@property (nonatomic, readonly) UIImage *toolBarDisplayImage;
@property (nonatomic, readonly) UIImage *toolBarKeyboardImage;
@property (nonatomic, readonly) UIImage *toolBarScannerImage;
@property (nonatomic, readonly) UIActivityIndicatorViewStyle indicatorStyle;

// item view
@property (nonatomic, readonly) UIImage *itemDeleteButtonImage;
@property (nonatomic, readonly) UIImage *itemTitleBarImage;
@property (nonatomic, readonly) UIColor *itemTitleColor;
@property (nonatomic, readonly) UIColor *tableViewBacgroundColor1;
@property (nonatomic, readonly) UIColor *tableViewBacgroundColor2;
@property (nonatomic, readonly) UIColor *itemSubtotalBackgroundColor;

+ (ePOSSkinManager *)sharedSkinManager;

- (NSString *)keyboardTitleFromTag:(NSInteger)tag;
- (void)drawKeyboard:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name tag:(NSInteger)tag;
- (void)drawTotalBase:(CGContextRef)context rect:(CGRect)rect;
- (void)drawItemDeleteButton:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name;
- (void)drawItemBase:(CGContextRef)context rect:(CGRect)rect;

@end
