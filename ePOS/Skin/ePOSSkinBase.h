//
//  ePOSSkinBase.h
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ePOSSkinManager.h"

#define EPOS_ITEM_HEADER_POSITION_Y (60.)
#define EPOS_ITEM_TABLE_POSITION_Y (528.)
#define EPOS_ITEM_SUBTOTAL_POSITION_Y (534.)
#define EPOS_ITEM_TABLE_ITEM_POSITION_X (272.)
#define EPOS_ITEM_TABLE_PRICE_POSITION_X (369.)
#define EPOS_ITEM_TABLE_QTY_POSITION_X (459.)

@interface ePOSSkinBase : NSObject

@property (nonatomic, readonly) ePOSSkinManager *manager;

// view
@property (nonatomic, readonly) UIImage *backgroundImage;
@property (nonatomic, readonly) UIColor *foregroundColor;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UIColor *hilightColor;

// keyboard
@property (nonatomic, readonly) UIImage *keyboardNumberImage;
@property (nonatomic, readonly) UIImage *keyboardControlImage;
@property (nonatomic, readonly) UIImage *keyboardCashImage;
@property (nonatomic, readonly) UIImage *paymentImage;

// toolbar
@property (nonatomic, readonly) UIImage *toolBarImage;
@property (nonatomic, readonly) UIImage *toolBarButtonSkin;
@property (nonatomic, readonly) UIImage *toolBarButtonSettings;
@property (nonatomic, readonly) UIImage *toolBarButtonLanguageJP;
@property (nonatomic, readonly) UIImage *toolBarButtonLanguageJPkanji;
@property (nonatomic, readonly) UIImage *toolBarButtonLanguageEN;
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
@property (nonatomic, readonly) UIColor *itemDeleteButtonTitleColor;
@property (nonatomic, readonly) UIImage *itemTitleBarImage;
@property (nonatomic, readonly) UIColor *itemTitleColor;
@property (nonatomic, readonly) UIColor *tableViewBacgroundColor1;
@property (nonatomic, readonly) UIColor *tableViewBacgroundColor2;
@property (nonatomic, readonly) UIColor *itemSubtotalBackgroundColor;


// keyboard
- (void)drawKeyboard:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name tag:(NSInteger)tag;
- (void)drawHighlightKeyboard:(CGContextRef)context rect:(CGRect)rect name:(NSString *)name tag:(NSInteger)tag;

// total
- (void)drawTotalBase:(CGContextRef)context rect:(CGRect)rect;

// item view
- (void)drawItemDeleteButton:(CGContextRef)context rect:(CGRect)rect isHighlighted:(BOOL)isHighlighted name:(NSString *)name;
- (void)drawItemBase:(CGContextRef)context rect:(CGRect)rect;

// common protect
- (CGFloat)fontSizeFromTag:(NSInteger)tag;

@end
