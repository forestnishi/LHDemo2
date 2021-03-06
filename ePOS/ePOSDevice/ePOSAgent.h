//
//  ePOSAgent.h
//  ePOS
//
//  Created by komatsu on 2014/06/23.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ePOS2.h"

typedef void (^ePosAgentCompletionHandler)(int result);
typedef void (^ePosAgentScannerCompletionHandler)(NSString *scanCode);
typedef void (^ePosAgentPrintCompletionHandler)(Epos2Printer* printerObj,int code, Epos2PrinterStatusInfo* status, NSString* printJobId);

@interface ePOSAgent : NSObject
// default value
@property(nonatomic) int lang;
@property(nonatomic) NSUserDefaults *def;

@property (nonatomic) BOOL isEposPrinter;
@property (nonatomic) BOOL isEposDisplay;
@property (nonatomic) BOOL isEposScanner;
@property (nonatomic) BOOL isEPosKeyboard;

@property (nonatomic) BOOL connect;

@property(nonatomic) BOOL isMarqueeScrolling;
@property(nonatomic) int slideNumber;
@property(nonatomic) int totalslideNumber;
@property(nonatomic) int RegisterImageNunber;
@property(nonatomic) NSTimer * timer;
@property(nonatomic) BOOL isDLTimerStarted;
// 任意のコールバックメソッドを登録するための変数　セレクタ名をセットして使用する
@property(nonatomic)  NSString* currentSelector;


+ (ePOSAgent *)sharedAgent;

- (void)connectIPAddress:(NSString *)ipaddress deviceIDs:(NSDictionary *)deviceDic  completion:(ePosAgentCompletionHandler)completion;
/*- (void)connectIPAddress:(NSString *)ipaddress
               printerID:(NSString *)printerID
               displayID:(NSString *)displayID
               scannerID:(NSString *)scannerID
              completion:(ePosAgentCompletionHandler)completion;*/

- (void)disconnectCompletion:(ePosAgentCompletionHandler)completion;
/*
- (void)createPrinterID:(NSString *)printerID completion:(ePosAgentCompletionHandler)completion;
- (void)createDisplayID:(NSString *)displayID completion:(ePosAgentCompletionHandler)completion;
- (void)createScannerID:(NSString *)scannerID completion:(ePosAgentCompletionHandler)completion;
*/
// scanner
- (void)startScanCompletion:(ePosAgentScannerCompletionHandler)completion;

// Printer
- (void)startPrintCompletion:(ePosAgentPrintCompletionHandler)completion;
- (int)clearCommandBuffer;
- (int)addTextAlign:(int)align;
- (int)addImage:(UIImage *)data X:(long)x Y:(long)y Width:(long)width Height:(long)height Color:(int)color Mode:(int)mode;
- (int)addFeed;
- (int)addText:(NSString *)data;
- (int)addTextStyle:(int)reverse Ul:(int)ul Em:(int)em Color:(int)color;
- (int)addTextSize:(long)width Height:(long)height;
- (int)addCut:(int)type;
- (int)addTextLang:(int)lang;
- (int)addBarcode:(NSString *)data Type:(int)type Hri:(int)hri Font:(int)font Width:(long)width Height:(long)height;
- (int)addCommand:(NSData *)data;
- (int)sendData;
- (int)addPulse;

// display
- (int)resetDisplay;
- (int)clearDisplay;
- (int)displayAllingedText:(NSString*)itemStr valueStr:(NSString*)valueStr yPosition:(NSInteger)yPosition;
- (int)displayAllingedTextLines:(NSString*)itemStr valueStr:(NSString*)valueStr itemStr2:(NSString *)itemStr2 valueStr2:(NSString *)valueStr2;
- (int)displayAllingedTextLines:(NSString*)itemStr depositValue:(NSString*)valueStr totalAmount:(NSString *)itemStr2 totalAmountValue:(NSString *)valueStr2 dispence:(NSString *)itemStr3 dispenseValue:(NSString *)valueStr3;
- (int)displayMarqeeText:(NSString *)string;
- (void)showSlide;
- (void)showD70Marquee;
-(void)finishD70Connect;
- (void)registerDownloadImage;
-(void)enableMarquee;

@end
