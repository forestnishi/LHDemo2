//
//  ePOSUserDefault.h
//  ePOS
//
//  Created by komatsu on 2014/06/23.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>

// 
extern NSString * const ePOSDefaultIPAddressKey;
extern NSString * const ePOSDefaultPrinterIDKey;
extern NSString * const ePOSDefaultDisplayIDKey;
extern NSString * const ePOSDefaultScannerIDKey;

extern NSString * const ePOSDefaultValidPrinterKey;
extern NSString * const ePOSDefaultValidScannerKey;
extern NSString * const ePOSDefaultValidDisplayKey;
extern NSString * const ePOSDefaultValidKeyboardKey;

extern NSString * const ePOSCurrentProductFileKey;

extern NSString * const ePOSDefaultLanguageKey;
extern NSString * const ePOSDefaultSkinTypeKey;

extern NSString * const ePOSDefaultCheckNumberKey;

extern NSString * const ePOSDefaultPaperWidthKey;
extern NSString * const ePOSDefaultPrintColumnKey;
extern NSString * const ePOSDisplayModelKey;
extern NSString * const ePOSDisplayViewKey;
extern BOOL isPrinterConnected;
extern BOOL isDisplayConnected;
extern BOOL isScannerConnected;
extern BOOL isDisplayLandscape;
extern BOOL isDownloadingImages;
extern int DLimgStatus;
extern BOOL isAccounting;

@interface ePOSUserDefault : NSObject
@end
