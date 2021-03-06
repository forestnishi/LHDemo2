//
//  ePOSUserDefault.m
//  ePOS
//
//  Created by komatsu on 2014/06/23.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSUserDefault.h"
#import "ePOS2.h"

// key Value 型の値として　NSUserDefaultに情報を格納する。以下はそのためのkey情報

// 各デバイスの論理名として利用している
NSString * const ePOSDefaultIPAddressKey                = @"ePOSDefaultIPAddressKey";
NSString * const ePOSDefaultPrinterIDKey                = @"ePOSDefaultPrinterIDKey";
NSString * const ePOSDefaultDisplayIDKey                = @"ePOSDefaultDisplayIDKey";
NSString * const ePOSDefaultScannerIDKey                = @"ePOSDefaultScannerIDKey";

// 各デバイスの利用の有無を示す値
NSString * const ePOSDefaultValidPrinterKey             = @"ePOSDefaultValidPrinterKey";
NSString * const ePOSDefaultValidScannerKey             = @"ePOSDefaultValidScannerKey";
NSString * const ePOSDefaultValidDisplayKey             = @"ePOSDefaultValidDisplayKey";
NSString * const ePOSDefaultValidKeyboardKey             = @"ePOSDefaultValidKeyboardKey";

// その他の設定情報
NSString * const ePOSCurrentProductFileKey              = @"ePOSCurrentProductFileKey";
NSString * const ePOSDefaultLanguageKey                 = @"ePOSDefaultLanguageKey";
NSString * const ePOSDefaultSkinTypeKey                 = @"ePOSDefaultSkinTypeKey";
NSString * const ePOSDefaultCheckNumberKey              = @"ePOSDefaultCheckNumberKey";
NSString * const ePOSDefaultPaperWidthKey               = @"ePOSDefaultPaperWidthKey";
NSString * const ePOSDefaultPrintColumnKey              = @"ePOSDefaultPrintColumnKey";
NSString * const ePOSDisplayModelKey                      = @"ePOSDisplayModelKey";
NSString * const ePOSDisplayViewKey                      = @"ePOSDisplayViewKey";
BOOL isPrinterConnected = FALSE;
BOOL isDisplayConnected = FALSE;
BOOL isScannerConnected = FALSE;
BOOL isDisplayLandscape = FALSE;
BOOL isDownloadingImages = TRUE;
int DLimgStatus = 0;
BOOL isAccounting = FALSE;
@implementation ePOSUserDefault
@end
