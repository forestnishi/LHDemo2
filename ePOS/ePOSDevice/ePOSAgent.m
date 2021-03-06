//
//  ePOSAgent.m
//  ePOS
//
//  Created by komatsu on 2014/06/23.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSAgent.h"
#import "ePOS2.h"
#import "ePOSSkinManager.h"
#import "ShowMsg.h"
#import "ePOSUserDefault.h"


#define DISPLAY_LINE_MAX    20

@interface ePOSAgent() <Epos2ScanDelegate, Epos2ConnectionDelegate,Epos2DispReceiveDelegate>
@end

@implementation ePOSAgent
{
    //EposDevice  *_epsonDevice;
    Epos2Printer *_eposPrinter;
    Epos2LineDisplay *_eposDisplay;
    Epos2BarcodeScanner *_eposScanner;

    ePosAgentCompletionHandler _connectHandler;
    ePosAgentCompletionHandler _disconnectHandler;
    ePosAgentCompletionHandler _deleteDeviceHandler;
    ePosAgentCompletionHandler _createPrinterHandler;
    ePosAgentCompletionHandler _createDisplayHandler;
    ePosAgentCompletionHandler _createScannerHandler;
    ePosAgentScannerCompletionHandler _scanCompletionHandler;
    ePosAgentPrintCompletionHandler _printCompletionHandler;
    
    NSString *_printerID;
    NSString *_displayID;
    NSString *_scannerID;
}

static ePOSAgent *_agent = nil;

+ (ePOSAgent *)sharedAgent
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _agent = [[ePOSAgent alloc] init];
    });
    return _agent;
    
}

- (void)connectIPAddress:(NSString *)ipaddress deviceIDs:(NSDictionary *)deviceDic completion:(ePosAgentCompletionHandler)completion
{
    isDownloadingImages = NO;
    _timer = nil;
    DLimgStatus = 0;
    _printerID = nil;
    _scannerID = nil;
    _displayID = nil;
    // katayama
    NSString *strPrinter;
    NSString *strScanner;
    NSString *strDisplay;
    NSString *interface = [ipaddress substringToIndex:1];
    if( [interface isEqualToString:@"T"]) {
        //TCP接続の時はデバイスIDを付けて接続させる
        //strPrinter = [NSString stringWithFormat:@"%@ [%@]",ipaddress,[deviceDic objectForKey:@"printerID"]];
        strPrinter = [NSString stringWithFormat:@"%@[%@]",ipaddress,[deviceDic objectForKey:@"printerID"]];
        //strScanner = [NSString stringWithFormat:@"%@ [%@]",ipaddress,[deviceDic objectForKey:@"scannerID"]];
        strScanner = [NSString stringWithFormat:@"%@[%@]",ipaddress,[deviceDic objectForKey:@"scannerID"]];
        strDisplay = [NSString stringWithFormat:@"%@[%@]",ipaddress,[deviceDic objectForKey:@"displayID"]];
    }
    else {
        strPrinter = [NSString stringWithFormat:@"%@",ipaddress];
        strScanner = [NSString stringWithFormat:@"%@",ipaddress];
        strDisplay = [NSString stringWithFormat:@"%@",ipaddress];
    }

    
    _def = [NSUserDefaults standardUserDefaults];
    _isEposPrinter = [[_def objectForKey:@"ePOSDefaultValidPrinterKey"] boolValue];
    _isEposDisplay = [[_def objectForKey:@"ePOSDefaultValidDisplayKey"] boolValue];
    _isEposScanner = [[_def objectForKey:@"ePOSDefaultValidScannerKey"] boolValue];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // languate
        // ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
        //_lang = skinManager.language == ePOSLanguageEnglish ? EPOS2_LANG_EN : EPOS2_LANG_JA;
        _lang = (int)[_def integerForKey:@"ePOSDefaultLanguageKey"];
        _connectHandler = completion;
        
        //log
        int result = [Epos2Log setLogSettings:EPOS2_PERIOD_PERMANENT output:EPOS2_OUTPUT_STORAGE ipAddress:nil port:0 logSize:3 logLevel:EPOS2_LOGLEVEL_LOW];
        
        isAccounting = FALSE;
        if( _isEposPrinter ) {
            //init printer
            _eposPrinter = [[Epos2Printer alloc] initWithPrinterSeries:EPOS2_TM_M30II lang:EPOS2_MODEL_JAPANESE];
            
            if (_eposPrinter == nil) {
                [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
            }
            
            [_eposPrinter setReceiveEventDelegate:self];
            
            //connect Printer
            result = EPOS2_SUCCESS;
            //result = [_eposPrinter connect:ipaddress timeout:EPOS2_PARAM_DEFAULT];
            
            result = [_eposPrinter connect:strPrinter timeout:EPOS2_PARAM_DEFAULT];
            if (result != EPOS2_SUCCESS) {
                _isEposPrinter = false;
                [ShowMsg showErrorEpos:result method:@"connect(Printer)"];
                isPrinterConnected = FALSE;
            }
            else {
                isPrinterConnected = TRUE;
                _isEposPrinter = true;
            }
        }
        
        if( _isEposScanner ) {
            //int barcode
            _eposScanner = [[Epos2BarcodeScanner alloc] init];
            if (_eposScanner == nil) {
                [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
            }
            
            [_eposScanner setScanEventDelegate:self];
            
            //connect barcode
            result = [_eposScanner connect:strScanner timeout:EPOS2_PARAM_DEFAULT];
            if (result != EPOS2_SUCCESS) {
                _isEposScanner = false;
                [ShowMsg showErrorEpos:result method:@"connect(Scanner)"];
                isScannerConnected = FALSE;
            }
            else isScannerConnected = TRUE;
        }
        
        if( _isEposDisplay ) {
            //init display
            _isDLTimerStarted = FALSE;
            _eposDisplay = [[Epos2LineDisplay alloc]initWithDisplayModel:(int)[_def integerForKey:ePOSDisplayModelKey]];
            if (_eposDisplay == nil) {
                [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"initWithDisplayModel"];
            }
            [_eposDisplay setReceiveEventDelegate:self];
            
            //connect display
            int resultdisp = [_eposDisplay connect:strDisplay timeout:EPOS2_PARAM_DEFAULT];
            if (resultdisp != EPOS2_SUCCESS) {
                _isEposDisplay = false;
                //[ShowMsg showErrorEpos:result method:@"connect(Display)"];
                isDisplayConnected = FALSE;
            }
            else isDisplayConnected = TRUE;
            BOOL bSuccess = ( EPOS2_SUCCESS == result)? YES : NO;
            if( YES == bSuccess ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_connectHandler) {
                        _connectHandler(result);
                    }
                });
            }
            
            // special initialize for D70
            _isMarqueeScrolling = NO;
            isDownloadingImages = YES;
            DLimgStatus = 1;
            if( (int)[_def integerForKey:ePOSDisplayModelKey] == 3 && isDisplayLandscape == FALSE) {
                [_eposDisplay addStopSlideShow];
                [_eposDisplay addClearCurrentWindow];
                [_eposDisplay addCreateScreenCustom:EPOS2_PORTRAIT_LAYOUT_MODE_2 column:21 row:5];
                // セレクタをセットして送信する。コールバックがあったときにそのセレクタを呼び出し、次の処理を行う
                [self showDisplay:@"finishD70Connect"];

            }
            if( (int)[_def integerForKey:ePOSDisplayModelKey] == 3 && isDisplayLandscape == TRUE) {
                
                [_eposDisplay addStopSlideShow];
                [_eposDisplay addClearCurrentWindow];
                [_eposDisplay addCreateScreenCustom:EPOS2_LANDSCAPE_LAYOUT_MODE_2 column:21 row:5];
                // セレクタをセットして送信する。コールバックがあったときにそのセレクタを呼び出し、次の処理を行う
                [self showDisplay:@"finishD70Connect"];

            }
            if( (int)[_def integerForKey:ePOSDisplayModelKey] != 3 ) {
                // D70以外のケース：ダウンロードイメージを行わない
                isDownloadingImages = NO;
                DLimgStatus = 0;
            }
        }
        else {
            // カスタマディスプレイが選択されていないケース：ダウンロードイメージを行わない
            isDownloadingImages = NO;
            DLimgStatus = 0;
        }
    });
}


- (void)disconnectCompletion:(ePosAgentCompletionHandler)completion
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        _disconnectHandler = completion;
        
        //scanner
        int result = EPOS2_SUCCESS;
        if(_isEposScanner) {
            result = [_eposScanner disconnect];
            if (result != EPOS2_SUCCESS) {
                [ShowMsg showErrorEpos:result method:@"Disconnect(Scanner)"];
            }
            _eposScanner = nil;
            isScannerConnected = FALSE;
        }
        
        //display
        if(_isEposDisplay) {
            result = EPOS2_SUCCESS;
            result = [_eposDisplay disconnect];
            if (result != EPOS2_SUCCESS) {
                [ShowMsg showErrorEpos:result method:@"Disconnect(Display)"];
            }
            [_timer invalidate];
            _eposDisplay = nil;
            isDisplayConnected = FALSE;
        }
        
        
        //printer
        if(_isEposPrinter) {
            result = [_eposPrinter disconnect];
            if (result != EPOS2_SUCCESS) {
                [ShowMsg showErrorEpos:result method:@"disconnect(Printer)"];
            }
            _eposPrinter = nil;
            isPrinterConnected = FALSE;
        }
        
        
        DEBUG_LOG(@"_epson disconnect : %d", result);
        _connect = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_disconnectHandler) {
                _disconnectHandler(result);
            }
        });
    });
}


// scanner
#pragma mark - Scanner
- (void)startScanCompletion:(ePosAgentScannerCompletionHandler)completion
{
    _scanCompletionHandler = completion;
}

- (void)stopScan
{
    _scanCompletionHandler = nil;
}

// display
#pragma mark - Display
- (int)resetDisplay
{
    int result = EPOS2_SUCCESS;
    
    @try
    {
//        // reset
//        result = [_eposDisplay reset];
//        if(EDEV_OC_SUCCESS != result)
//        {
//            DEBUG_LOG(@"reset %d", result);
//            return result;
//        }
//
//        // initialize display
//        result = [_eposDisplay createWindow:1 X:1 Y:1 Width:20 Height:2 ScrollMode:EDEV_OC_SCROLL_OVERWRITE];
//        if(EDEV_OC_SUCCESS != result)
//        {
//            DEBUG_LOG(@"createWindow %d", result);
//            return result;
//        }
//
//        result = [_eposDisplay setCurrentWindow:1];
//        if(EDEV_OC_SUCCESS != result)
//        {
//            DEBUG_LOG(@"setCurrentWindow %d", result);
//            return result;
//        }
//
//        result = [_eposDisplay setCursorType:EDEV_OC_CURSOR_NONE];
//        if(EDEV_OC_SUCCESS != result)
//        {
//            DEBUG_LOG(@"setCursorType %d", result);
//            return result;
//        }
//
//        result = [_eposDisplay sendData];
//        if(EDEV_OC_SUCCESS != result)
//        {
//            DEBUG_LOG(@"sendData %d", result);
//            return result;
//        }
//
//        result = [_eposDisplay clearCommandBuffer];
//        if(EDEV_OC_SUCCESS != result)
//        {
//            DEBUG_LOG(@"clearCommandBuffer %d", result);
//            return result;
//        }
        result = [_eposDisplay addInitialize];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"reset %d", result);
            return result;
        }
    }
    @catch (NSException* exp)
    {
        return EPOS2_ERR_FAILURE;
    }

}

- (int)clearDisplay
{
    int result = EPOS2_SUCCESS;
    result = [_eposDisplay addClearCurrentWindow];
    if(EPOS2_SUCCESS != result)
    {
        DEBUG_LOG(@"addClearCurrentWindow");
        return result;
    }
    return result;
}


- (int)displayAllingedText:(NSString*)itemStr valueStr:(NSString*)valueStr yPosition:(NSInteger)yPosition
{
    int result = EPOS2_SUCCESS;
    
    [self addItemDisplay:itemStr valueStr:valueStr yPosition:yPosition];

    result = [self showDisplay:nil];
    
    return result;
}

- (int)displayAllingedTextLines:(NSString*)itemStr valueStr:(NSString*)valueStr itemStr2:(NSString *)itemStr2 valueStr2:(NSString *)valueStr2
{
    int result;
    result = [self clearDisplay];
    if(EPOS2_SUCCESS != result)
    {
        DEBUG_LOG(@"clearDisplay %d", result);
        return result;
    }
    
    [self addItemDisplay:itemStr valueStr:valueStr yPosition:1];
    if(EPOS2_SUCCESS != result)
    {
        DEBUG_LOG(@"displayAllingedText1 %d", result);
        return result;
    }

    if( (int)[_def integerForKey:ePOSDisplayModelKey] != 3 ) { // D70以外の設定
        [self addItemDisplay:itemStr2 valueStr:valueStr2 yPosition:2];
    }
    else {
        [self addItemDisplay:itemStr2 valueStr:valueStr2 yPosition:4];
    }
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"displayAllingedText2 %d", result);
            return result;
        }
    
    // display window
    result = [self showDisplay:nil];

    return result;
}


- (int)displayAllingedTextLines:(NSString*)itemStr depositValue:(NSString*)valueStr totalAmount:(NSString *)itemStr2 totalAmountValue:(NSString *)valueStr2 dispence:(NSString *)itemStr3 dispenseValue:(NSString *)valueStr3
{
    int result;
    result = [self clearDisplay];
    if(EPOS2_SUCCESS != result)
    {
        DEBUG_LOG(@"clearDisplay %d", result);
        return result;
    }
    // Deposit
    [self addItemDisplay:itemStr valueStr:valueStr yPosition:2];
    if(EPOS2_SUCCESS != result)
    {
        DEBUG_LOG(@"displayAllingedText1 %d", result);
        return result;
    }

    // total
        [self addItemDisplay:itemStr2 valueStr:valueStr2 yPosition:3];
  
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"displayAllingedText2 %d", result);
            return result;
        }
    
    // dispence
        [self addItemDisplay:itemStr3 valueStr:valueStr3 yPosition:4];
  
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"displayAllingedText3 %d", result);
            return result;
        }
    
    
    // display window
    result = [self showDisplay:nil];

    return result;
}


- (int)displayMarqeeText:(NSString *)string
{
    int result = 0;
    
   
    if( (int)[_def integerForKey:ePOSDisplayModelKey] != 3 ) { // D70以外の設定
        result = [self clearDisplay];
        _isMarqueeScrolling = YES;
        //result = [_eposDisplay addSetCursorPosition:10 y:1];
        result = [_eposDisplay addCreateTextArea:1 x:1 y:1 width:20 height:1 scrollMode:EPOS2_SCROLL_HORIZONTAL];
        DEBUG_LOG(@"add Marquee not D70");
        result = [_eposDisplay addMarqueeText:string format:EPOS2_MARQUEE_WALK unitWait:150 repeatWait:700 repeatCount:0 lang:_lang];
        
        result = [self showDisplay:nil];
    }
    else {
    }
    
    //result = [_eposDisplay addStartSlideShow:3000];
    //if(EPOS2_SUCCESS != result)
    //{
        //DEBUG_LOG(@"setCursorPosition %d", result);
        //eturn result;
    //}

    
    //ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    //_lang = skinManager.language == ePOSLanguageEnglish ? EPOS2_LANG_EN : EPOS2_LANG_JA;
   
    if(EPOS2_SUCCESS != result)
    {
        DEBUG_LOG(@"addMarquee %d", result);
        return result;
    }
    
    
    
    if(_isDLTimerStarted == FALSE ) {
        _isDLTimerStarted = TRUE;
        _timer = [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(showSlide) userInfo:nil repeats:YES];
    }

    return result;
}
// printer
#pragma mark - Printer
- (void)startPrintCompletion:(ePosAgentPrintCompletionHandler)completion
{
    if(_eposPrinter == nil) {
        completion(EPOS2_FALSE, -1, NULL, NULL);
    } else {
        _printCompletionHandler = completion;
    }
}

- (int)clearCommandBuffer
{
    return [_eposPrinter clearCommandBuffer];
}

- (int)addTextAlign:(int)align
{
    return [_eposPrinter addTextAlign:(int)align];
}

- (int) addImage:(UIImage *)data X:(long)x Y:(long)y Width:(long)width Height:(long)height Color:(int)color Mode:(int)mode
{
    return [_eposPrinter addImage:data x:x y:y width:width height:height color:color mode:mode halftone:EPOS2_PARAM_DEFAULT brightness:EPOS2_PARAM_DEFAULT compress:EPOS2_PARAM_DEFAULT];
}

- (int)addFeed
{
    return [_eposPrinter addFeedLine:1];
}

- (int)addText:(NSString *)data
{
    return [_eposPrinter addText:data];
}

- (int) addTextStyle:(int)reverse Ul:(int)ul Em:(int)em Color:(int)color
{
    return [_eposPrinter addTextStyle:reverse ul:ul em:em color:color];
}

- (int)addTextSize:(long)width Height:(long)height;
{
    return [_eposPrinter addTextSize:width height:height];
}

- (int) addCut:(int)type
{
    return [_eposPrinter addCut:type];
}

- (int)addTextLang:(int)lang
{
    return [_eposPrinter addTextLang:lang];
}

- (int)addBarcode:(NSString *)data Type:(int)type Hri:(int)hri Font:(int)font Width:(long)width Height:(long)height;
{
    return [_eposPrinter addBarcode:data type:type hri:hri font:font width:width height:height];
}

- (int)addCommand:(NSData *)data
{
    return [_eposPrinter addCommand:data];
}
- (int)sendData
{
    return [_eposPrinter sendData:5000];
}

- (int)addPulse
{
    return [_eposPrinter addPulse:EPOS2_PARAM_DEFAULT time:EPOS2_PULSE_200];
}

// --------------------------------------------------------------------------------------------------------------------
#pragma mark - Private
- (id)init
{
    self = [super init];
    if (self) {
        //_epsonDevice = [[EposDevice alloc] init];
        _connectHandler = nil;
        _disconnectHandler = nil;
        _deleteDeviceHandler = nil;
        _createPrinterHandler = nil;
        _createDisplayHandler = nil;
        _createScannerHandler = nil;
        _connect = NO;
        
        _isEPosKeyboard = NO;
        _isMarqueeScrolling = NO;
        _slideNumber = 0;
        _totalslideNumber = 3;
        _currentSelector = nil;
    }
    return self;
}

//#pragma mark - Callback


- (void) onPtrReceive:(Epos2Printer *)printerObj code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
{
    isAccounting = NO;
    DEBUG_LOG(@"INPUT : code%d", code);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_printCompletionHandler) {
            _printCompletionHandler(printerObj, code, status, printJobId);
        }
    });
    
    
}

//- (void)receiveDisplayEvent:(NSString*)ipAddress
//                   DeviceId:(NSString*)deviceId
//                    Success:(int)success
//                       Code:(int)code
//{
//    DEBUG_LOG(@"receiveDisplayEvent %zi", code);
//}


- (void)receiveScannerDataEvent:(NSString*)ipAddress
                       DeviceId:(NSString*)deviceId
                          Input:(NSString*)input
{
    DEBUG_LOG(@"INPUT : %@", input);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_scanCompletionHandler) {
            _scanCompletionHandler(input);
        }
    });

}

- (void) onScanData:(Epos2BarcodeScanner *)scannerObj scanData:(NSString *)scanData
{
    DEBUG_LOG(@"INPUT : %@", scanData);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_scanCompletionHandler) {
            _scanCompletionHandler(scanData);
        }
    });
    
}

- (int)addItemDisplay:(NSString *)itemStr valueStr:(NSString *)valueStr yPosition:(NSInteger)yPosition
{
    // 会計を始める
    isAccounting = YES;
    
    // stop slideshow
    _isDLTimerStarted = FALSE;
    [_timer invalidate];
    
    int result = EPOS2_SUCCESS;
    long valueStrLen = [valueStr length];
    long cursorPos = DISPLAY_LINE_MAX - valueStrLen;
    if( 1 > DISPLAY_LINE_MAX - valueStrLen)
    {
        cursorPos = 1;
    }
    _lang = (int)[_def integerForKey:@"ePOSDefaultLanguageKey"];
    
    if( _isMarqueeScrolling == YES )  result = [_eposDisplay addStopSlideShow];
    
    if( (int)[_def integerForKey:ePOSDisplayModelKey] != 3 ) { // D70以外の設定
        // add item
        result = [_eposDisplay addSetCursorPosition:1 y:yPosition];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"setCursorPosition %d", result);
            return result;
        }

        result = [_eposDisplay addText:itemStr lang:_lang];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"addText %d", result);
            return result;
        }
        
        // add value
        result = [_eposDisplay addSetCursorPosition:cursorPos y:yPosition];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"setCursorPosition %d", result);
            return result;
        }
        
        result = [_eposDisplay addText:@" "  lang:_lang];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"addText %d", result);
            return result;
        }
        
        result = [_eposDisplay addText:valueStr  lang:_lang];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"addText %d", result);
            return result;
        }
    }
    else {     //  for D70
        if( _isMarqueeScrolling == YES ) {
            result = [_eposDisplay addDestroyWindow:3];
            result = [_eposDisplay addDestroyWindow:2];
            result = [_eposDisplay addDestroyWindow:1];
            result = [_eposDisplay addDestroyTextArea:3];
            result = [_eposDisplay addDestroyTextArea:2];
            result = [_eposDisplay addDestroyTextArea:1];
            
            //result = [_eposDisplay addSetCurrentTextArea:1];
            //result = [_eposDisplay addBackgroundColor:EPOS2_ALL_ROWS r:0 g:0 b:0];
            //result = [_eposDisplay addSetCurrentTextArea:2];
            //result = [_eposDisplay addBackgroundColor:EPOS2_ALL_ROWS r:0 g:0 b:0];
            //result = [_eposDisplay addSetCurrentTextArea:3];
            //result = [_eposDisplay addBackgroundColor:EPOS2_ALL_ROWS r:0 g:0 b:0];

            //result = [_eposDisplay addDestroyWindow:1];
            result = [_eposDisplay addCreateTextArea:1 x:1 y:1 width:21 height:5 scrollMode:EPOS2_SCROLL_OVERWRITE];
            result = [_eposDisplay addSetCurrentTextArea:1];
            result = [_eposDisplay addClearCurrentTextArea];
            _isMarqueeScrolling = NO;
        }
        // add item
        
        int spaceColemn = 1;
        result = [_eposDisplay addSetCursorPosition:1+spaceColemn y:yPosition];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"setCursorPosition %d", result);
            return result;
        }

        result = [_eposDisplay addText:itemStr lang:_lang];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"addText %d", result);
            return result;
        }
        
        // add value
        result = [_eposDisplay addSetCursorPosition:cursorPos+spaceColemn y:yPosition];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"setCursorPosition %d", result);
            return result;
        }
        
        result = [_eposDisplay addText:@" "  lang:_lang];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"addText %d", result);
            return result;
        }
        
        if( ![itemStr isEqualToString:@"小計"] && ![itemStr isEqualToString:@"お預り"] && ![itemStr isEqualToString:@"お買上"] && ![itemStr isEqualToString:@"お釣り"] ) {
            
            // アイテムを表示する
            result = [_eposDisplay addSetCursorPosition:cursorPos+spaceColemn y:yPosition+1];
        }
        else {
            result = [_eposDisplay addSetCursorPosition:cursorPos+spaceColemn y:yPosition];
        }
        
        if( [itemStr isEqualToString:@"お預り"] || [itemStr isEqualToString:@"お買上"] || [itemStr isEqualToString:@"お釣り"] ) {
            [_eposDisplay addBackgroundColor:EPOS2_ALL_ROWS r:0 g:40 b:30];
        }
        result = [_eposDisplay addText:valueStr  lang:_lang];
        if(EPOS2_SUCCESS != result)
        {
            DEBUG_LOG(@"addText %d", result);
            return result;
        }
    }
    
    return result;
}

- (int)showDisplay :(NSString*)specifiedSelector
{
    int result;
    // セレクタの指定があったときにはセレクタ用変数に格納した後sendDataする
    if( !( [specifiedSelector isEqual:[NSNull null]] ) ) {
        _currentSelector = specifiedSelector;
    }
   
    result = [_eposDisplay sendData];
    if(EPOS2_SUCCESS != result)
    {
        DEBUG_LOG(@"sendData error %d", result);
        return result;
    }
    
    result = [_eposDisplay clearCommandBuffer];
    if(EPOS2_SUCCESS != result)
    {
        DEBUG_LOG(@"clearCommandBuffer %d", result);
        return result;
    }
    return result;
}

/*
- (void)onConnection:(id)deviceObj eventType:(int)eventType {
    <#code#>
}
*/

- (void)onDispReceive:(Epos2LineDisplay *)displayObj code:(int)code {
    DEBUG_LOG(@"onDispRec %d  select=%@", code, _currentSelector);
    if( code != 0) {
        int ii = 0;
    }
    NSString* nowSelector = _currentSelector;
    NSTimeInterval waittime = 0.0;
    if( nowSelector != [NSNull null] && [nowSelector length] > 0)  {
        if( [nowSelector isEqualToString:@"registerDownloadImage"] ) waittime = 0.1;
        [self performSelector:NSSelectorFromString( nowSelector ) withObject:nil afterDelay:waittime];
    }

}

/*
- (void)onConnection:(id)deviceObj eventType:(int)eventType {
    <#code#>
}

- (void)onDispReceive:(Epos2LineDisplay *)displayObj code:(int)code {
    <#code#>
}*/

- (void)showSlide {
    //DEBUG_LOG(@"show Slide");
    _slideNumber++;
    _slideNumber = _slideNumber % _totalslideNumber;
    int keycode2 = 100;
    [_eposDisplay addClearCurrentTextArea];
    if( isDisplayLandscape == FALSE) {
        keycode2 = 100 + _slideNumber;
        [_eposDisplay addDownloadImage:100 key2:keycode2 dotX:0 dotY:0 width:480 height:400];
    }
    else {
        keycode2 = 103 + _slideNumber;
        [_eposDisplay addDownloadImage:100 key2:keycode2 dotX:0 dotY:0 width:400 height:480];
    }
    
    // showD70Marquee　セレクタを指定して送信する
    [self showDisplay:@"showD70Marquee"];
}

- (void)showD70Marquee {
    ePOSSkinManager *_skinManager;
    DEBUG_LOG(@"add Marquee");
    
   int result = [_eposDisplay addDestroyTextArea:1];
    //result = [_eposDisplay addDestroyTextArea:2];
    result = [_eposDisplay addCreateTextArea:1 x:1 y:1 width:21 height:2 scrollMode:EPOS2_SCROLL_HORIZONTAL];
    result = [_eposDisplay addSetCurrentTextArea:1];
    result = [_eposDisplay addBackgroundColor:EPOS2_ALL_ROWS r:0 g:0 b:64];
    
    result = [_eposDisplay addCreateTextArea:3 x:1 y:4 width:21 height:2 scrollMode:EPOS2_SCROLL_HORIZONTAL];
    result = [_eposDisplay addSetCurrentTextArea:3];
    result = [_eposDisplay addBackgroundColor:EPOS2_ALL_ROWS r:0 g:0 b:64];

    result = [_eposDisplay addCreateTextArea:2 x:1 y:3 width:21 height:1 scrollMode:EPOS2_SCROLL_HORIZONTAL];
    result = [_eposDisplay addSetCurrentTextArea:2];
    result = [_eposDisplay addBackgroundColor:EPOS2_ALL_ROWS r:0 g:0 b:64];
     

    [_eposDisplay addMarqueeText:EPOSLocalizedString(@"      いらっしゃいませ Welcome to epson shop", _skinManager.language, nil) format:EPOS2_MARQUEE_WALK unitWait:140 repeatWait:1250 repeatCount:0 lang:_lang];
    _isMarqueeScrolling = YES;
    [self showDisplay:nil];
}

-(void)finishD70Connect {
    DEBUG_LOG( @"finishD70Connect");
    // D70への接続と初期化処理が終わったら、次にダウンロードイメージの処理にすすむ
    // register DownloadImage
    _RegisterImageNunber = 3;
    [self registerDownloadImage];
}

-(void)registerDownloadImage {
    DEBUG_LOG( @"registerDownloadImage RegNum = %d",  _RegisterImageNunber);
    isDownloadingImages = TRUE;
    DLimgStatus = 1;
    if( _RegisterImageNunber == 0 ) {
        [self performSelector:@selector(enableMarquee) withObject:nil afterDelay:0.1];
        return;
    }
    NSString* imgfilePath = nil;
    NSData* imgdata = nil;
    int rc = 0;
    switch( _RegisterImageNunber ) {
        case 3:
            if( isDisplayLandscape == FALSE) {
                imgfilePath = [[NSBundle mainBundle] pathForResource:@"480x400-1" ofType:@"png"];
                imgdata = [NSData  dataWithContentsOfFile:imgfilePath options:NSDataReadingMapped error:nil];
                    rc = [_eposDisplay addRegisterDownloadImage:imgdata key1:100 key2:100];                    
            }
            else {
                imgfilePath = [[NSBundle mainBundle] pathForResource:@"clearance_400x480" ofType:@"png"];
                imgdata = [NSData  dataWithContentsOfFile:imgfilePath options:NSDataReadingMapped error:nil];
                rc = [_eposDisplay addRegisterDownloadImage:imgdata key1:100 key2:103];
            }
            break;
        case 2:
            if( isDisplayLandscape == FALSE) {
                imgfilePath = [[NSBundle mainBundle] pathForResource:@"480x400-2" ofType:@"png"];
                imgdata = [NSData  dataWithContentsOfFile:imgfilePath options:NSDataReadingMapped error:nil];
                [_eposDisplay addRegisterDownloadImage:imgdata key1:100 key2:101];
            }
            else {
                imgfilePath = [[NSBundle mainBundle] pathForResource:@"maeda_アパレル400×480" ofType:@"png"];
                imgdata = [NSData  dataWithContentsOfFile:imgfilePath options:NSDataReadingMapped error:nil];
                [_eposDisplay addRegisterDownloadImage:imgdata key1:100 key2:104];
            }
            break;
        case 1:
            if( isDisplayLandscape == FALSE) {
                imgfilePath = [[NSBundle mainBundle] pathForResource:@"480x400-3" ofType:@"png"];
                imgdata = [NSData  dataWithContentsOfFile:imgfilePath options:NSDataReadingMapped error:nil];
                [_eposDisplay addRegisterDownloadImage:imgdata key1:100 key2:102];
            }
            else {
                imgfilePath = [[NSBundle mainBundle] pathForResource:@"maeda_アパレル400×480_2" ofType:@"png"];
                imgdata = [NSData  dataWithContentsOfFile:imgfilePath options:NSDataReadingMapped error:nil];
                [_eposDisplay addRegisterDownloadImage:imgdata key1:100 key2:105];
            }
        default:
            break;
    }
        // カウンタを減らして送信実行する
        _RegisterImageNunber--;
        // 残り画像がある場合はこのメソッドをセレクタ変数に登録してshowDisplayする
    if( _RegisterImageNunber >= 0 ) {
        [self showDisplay:@"registerDownloadImage"];
    }
    //    else [self showDisplay:nil];
}

-(void) enableMarquee {
    DEBUG_LOG(@"enableMarquee isDownload NO");
    isDownloadingImages = NO;
    DLimgStatus = 2;
}

@end
