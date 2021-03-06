//
//  ePOSPrintManager.m
//  ePOS
//
//  Created by komatsu on 2014/07/07.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSPrintManager.h"
#import "ePOSAgent.h"
#import "ePOSItemManager.h"
#import "ePOSDataManager.h"
#import "ePOSSkinManager.h"
#import "ePOS2.h"
#import "ePOSUserDefault.h"


#define CHARCTER_MARGIN 1

#define IF_ERROR_COMPLETION     if(EPOS2_SUCCESS != result) { \
                                    if(completion) completion(0, result, nil, nil); \
                                } \

#define IF_ERROR_RETURN         if(EPOS2_SUCCESS != result) { \
                                    return result; \
                                } \


@implementation ePOSPrintManager

- (void)printReceipt:(Boolean) memberID: (NSArray *)sign completion:(ePosAgentPrintCompletionHandler)completion
{
    
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    ePOSItemManager *itemManager = [ePOSItemManager sharedItemManager];
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    
    [agent startPrintCompletion:^(Epos2Printer* printerObj,int code, Epos2PrinterStatusInfo* status, NSString* printJobId) {
        if(completion) completion(printerObj, code, status, printJobId);
    }];

    int result = EPOS2_SUCCESS;

    result = [agent clearCommandBuffer];
    IF_ERROR_COMPLETION
    
    // Language
    if(skinManager.language == ePOSLanguageJapanese) {
        result = [agent addTextLang:EPOS2_LANG_JA];
    } else {
        result = [agent addTextLang:EPOS2_LANG_EN];
    }
    IF_ERROR_COMPLETION
    
    result = [agent addPulse];
    
    // LOGO
    result = [agent addTextAlign:EPOS2_ALIGN_CENTER];
    IF_ERROR_COMPLETION

    UIImage* image = [UIImage imageNamed:@"store.png"];
    result = [agent addImage:image X:0 Y:0 Width:(long)image.size.width Height:(long)image.size.height
                       Color:EPOS2_PARAM_DEFAULT Mode:EPOS2_MODE_MONO];
    IF_ERROR_COMPLETION

    result = [agent addFeed];
    IF_ERROR_COMPLETION
    
    // address & phone
    result = [agent addTextAlign:EPOS2_ALIGN_CENTER];
    IF_ERROR_COMPLETION

    result = [agent addText:EPOSLocalizedString(@"THE STORE\n", skinManager.language, nil)];
    IF_ERROR_COMPLETION
    
    result = [agent addText:EPOSLocalizedString(@"Japan\n", skinManager.language, nil)];
    IF_ERROR_COMPLETION
    
    result = [agent addText:EPOSLocalizedString(@"03-XXXX-XXXX\n\n", skinManager.language, nil)];
    IF_ERROR_COMPLETION
    
    result = [agent addText:EPOSLocalizedString(@"Thank you for shopping\n", skinManager.language, nil)];
    IF_ERROR_COMPLETION
    
    result = [agent addText:EPOSLocalizedString(@"Please visit us again soon\n\n", skinManager.language, nil)];
    IF_ERROR_COMPLETION
    
    result = [agent addFeed];
    IF_ERROR_COMPLETION

    // date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(skinManager.language == ePOSLanguageJapanese ) {
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ja_JP"]];
    } else {
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    }
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];

    NSDate *date = [NSDate date];
    NSString *dateString = [formatter stringFromDate:date];
    result = [agent addText:dateString];
    IF_ERROR_COMPLETION
    
    result = [agent addFeed];
    IF_ERROR_COMPLETION
    
    result = [agent addFeed];
    IF_ERROR_COMPLETION

    // item
    result = [agent addTextAlign:EPOS2_ALIGN_LEFT];
    IF_ERROR_COMPLETION

    for(NSInteger i = 0 ; i < itemManager.count ; i++) {
        NSString *name = [itemManager nameAtIndex:i];
        NSInteger qty = [itemManager quantityAtIndex:i];
        NSString *amount = [itemManager amountAtIndex:i];
        
        NSString *item = [self makeItemName:name qty:qty amount:amount];
        result = [agent addText:item];
        IF_ERROR_COMPLETION
        
        result = [agent addFeed];
        IF_ERROR_COMPLETION

    }
    
    result = [agent addFeed];
    IF_ERROR_COMPLETION

    // net
    result = [self printTotal:EPOSLocalizedString(@"  NET ", skinManager.language, nil)
                  isItemLarge:YES value:itemManager.net isValueLarge:YES space:CHARCTER_MARGIN];
    IF_ERROR_COMPLETION

    // tax
    result = [self printTotal:EPOSLocalizedString(@"  TAX ", skinManager.language, nil)
                  isItemLarge:YES value:itemManager.tax isValueLarge:YES space:CHARCTER_MARGIN];
    IF_ERROR_COMPLETION

    // total
    result = [self printTotal:EPOSLocalizedString(@" TOTAL", skinManager.language, nil)
                  isItemLarge:YES value:itemManager.total isValueLarge:YES space:CHARCTER_MARGIN];
    IF_ERROR_COMPLETION

    result = [agent addFeed];
    IF_ERROR_COMPLETION

    if(skinManager.language == ePOSLanguageJapanese)
    {
        // Deposit
        result = [self printTotal:EPOSLocalizedString(@"Deposit", skinManager.language, nil)
                      isItemLarge:YES value:itemManager.deposit isValueLarge:YES space:CHARCTER_MARGIN];
        IF_ERROR_COMPLETION

        // Change
        result = [self printTotal:EPOSLocalizedString(@"Change", skinManager.language, nil)
                      isItemLarge:YES value:itemManager.change isValueLarge:YES space:CHARCTER_MARGIN];
        IF_ERROR_COMPLETION
        
        result = [agent addFeed];
        IF_ERROR_COMPLETION
    }
    
    // card
    if(sign) {
        result = [agent addTextAlign:EPOS2_ALIGN_CENTER];
        IF_ERROR_COMPLETION

        UIImage *signImage = [itemManager createSign:sign width:[self maxWidth]];
        result = [agent addImage:signImage X:0 Y:0 Width:signImage.size.width Height:signImage.size.height Color:EPOS2_PARAM_DEFAULT Mode:EPOS2_MODE_MONO];
        IF_ERROR_COMPLETION

        result = [agent addFeed];
        IF_ERROR_COMPLETION
    }
    
    // last
    result = [agent addTextSize:1 Height:1];
    IF_ERROR_COMPLETION

    result = [agent addTextAlign:EPOS2_ALIGN_RIGHT];
    IF_ERROR_COMPLETION
    
    // Add start 2018/3/1
    if(memberID){
        result = [agent addText:@"-----------------------------------------------\n"];
        IF_ERROR_COMPLETION
        
        result = [agent addText:@"ポイント会員ID        2874900190406\n"];
        IF_ERROR_COMPLETION
        
        result = [agent addText:@"今回発生ポイント       30P\n"];
        IF_ERROR_COMPLETION
        
        result = [agent addText:@"合計残高ポイント       740P\n"];
        IF_ERROR_COMPLETION
        
    }
    // Add end 2018/3/1
    
    NSString *footer = [NSString stringWithFormat:EPOSLocalizedString(@"%d lines%04d\n", skinManager.language, nil), itemManager.count, itemManager.currentCheckNumber];
    result = [agent addText:footer];
    IF_ERROR_COMPLETION

    result = [agent addFeed];
    IF_ERROR_COMPLETION
    
    result = [agent addCut:EPOS2_CUT_FEED];
    IF_ERROR_COMPLETION
    
    result = [agent sendData];
    IF_ERROR_COMPLETION

}

// Add start 2018/3/1
- (void)printTaxFree:(NSString*)taxForTaxFree : (NSString*)netForTaxFree completion:(ePosAgentPrintCompletionHandler)completion{
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    ePOSItemManager *itemManager = [ePOSItemManager sharedItemManager];
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    
    [agent startPrintCompletion:^(Epos2Printer* printerObj,int code, Epos2PrinterStatusInfo* status, NSString* printJobId) {
        if(completion) completion(printerObj, code, status, printJobId);
    }];
    
    int result = EPOS2_SUCCESS;
    
    result = [agent clearCommandBuffer];
    IF_ERROR_COMPLETION
    
    // Language
    result = [agent addTextLang:EPOS2_LANG_JA];
    IF_ERROR_COMPLETION
    
    static unsigned char cmdEscpos[] = {0x1b,0x52,0x08,0x1b,0x74,0x01,0x1c,0x43,0x01,0x1b,0x2d,0x01,0x1c,0x2d,0x01,0x1b,0x61,0x01,0x1c,0x45,0x01,0x1b,0x20,0x01,0x1c,0x53,0x00,0x01};
    NSData *data = [[NSData alloc] initWithBytes:cmdEscpos length:sizeof(cmdEscpos)];
    result = [agent addCommand:data];
    IF_ERROR_COMPLETION
    
    //輸出免税物品購入記録票------------------------------------
    result = [agent addText:@"輸出免税物品購入記録票\n"
              "Record of Purchase of Consumption\n"
              "Tax-Exempt Commodities for Export\n"];
    IF_ERROR_COMPLETION
    
    static unsigned char cmdEscpos2[] = {0x1b,0x2d,0x00,0x1c,0x2d,0x00,0x1b,0x61,0x00,0x1c,0x45,0x00,0x1b,0x20,0x00,0x1c,0x53,0x00,0x00};
    NSData *data2 = [[NSData alloc] initWithBytes:cmdEscpos2 length:sizeof(cmdEscpos2)];
    result = [agent addCommand:data2];
    IF_ERROR_COMPLETION
    
    static unsigned char cmdEscpos3[] = {0x1c,0x28,0x41,0x02,0x00,0x30,0x01,0x1b,0x33,0x22};
    NSData *data3 = [[NSData alloc] initWithBytes:cmdEscpos3 length:sizeof(cmdEscpos3)];
    result = [agent addCommand:data3];
    IF_ERROR_COMPLETION
    
    result = [agent addText:@"① 本邦から出国する際又は居住者となる際に、その出港地を所\n"
              "　轄する税関長又はその住所若しくは居所の所在地を所轄する\n"
              "　税務署長に購入記録票を提出しなければなりません。\n"
              "② 本邦から出国するまでは購入記録票を旅券等から切り離して\n"
              "　はいけません。\n"
              "③ 免税で購入した物品を本邦からの出国の際に所持していなか\n"
              "　った場合には、その購入した物品について免除された消費税\n"
              "　額（地方消費税を含む。）に相当する額を徴収されます。\n"
              "④ ③の場合において、災害その他やむを得ない事情により免税\n"
              "　で購入した物品を亡失したため輸出しないことにつき税関長\n"
              "　の承認を受けたとき、又は既に輸出したことを証する書類を\n"
              "  出港地を所轄する税関長に提出したときは、消費税額（地方\n"
              "  消費税を含む。）に相当する額を徴収されません。\n"];
    IF_ERROR_COMPLETION
    
    static unsigned char cmdEscpos4[] = {0x1b,0x4d,0x32,0x1b,0x33,0x22};
    NSData *data4 = [[NSData alloc] initWithBytes:cmdEscpos4 length:sizeof(cmdEscpos4)];
    result = [agent addCommand:data4];
    IF_ERROR_COMPLETION
    result = [agent addText:@"① When departing Japan, or if becoming a resident of Japan,\n"
              "  you are required to submit your ”Record of Purchase Card”\n"
              "  to either the Director of Customs that has jurisdiction over\n"
              "  your departure location or the head of the tax office that \n"
              "  has jurisdiction over your place of residence or address. \n"
              "② You must not remove the ”Record of Purchase Card”from your\n"
              " passport etc. until after you have departed Japan. \n"
              "③ If you are not in possession of item(s) purchased tax free, \n"
              "  that are listed on the“Record of Purchase Card”, at the \n"
              "  time of departure from Japan, an amount equivalent to the \n"
              "  consumption tax amount (including local consumption tax) that\n"
              "  was exempted at the time of purchase will be collected before\n"
              "  your departure from Japan. \n"
              "④ In the case of ③ if you do not possess listed item(s) at \n"
              "  the time of departure, if the Director of Customs has \n"
              "  acknowledged that item(s) you purchased tax free will not be \n"
              "  exported as a result of being lost in a disaster or due to \n"
              "  other unavoidable circumstances, or alternatively, if you have\n"
              "  submitted documents to the Director of Customs that has \n"
              "  jurisdiction over your departure location that verifies the \n"
              "  item(s) has already been exported an amount equivalent to the \n"
              "  consumption tax amount (including local consumption tax) will \n"
              "  not be collected.\n"
              "_______________________________________________________\n"];
    IF_ERROR_COMPLETION
    
    static unsigned char cmdEscpos5[] = {0x1b,0x4d,0x31,0x1b,0x33,0x22};
    NSData *data5 = [[NSData alloc] initWithBytes:cmdEscpos5 length:sizeof(cmdEscpos5)];
    result = [agent addCommand:data5];
    IF_ERROR_COMPLETION
    result = [agent addText:@"購入者氏名/Name in full:       SHINJUKU TARO\n"
              "国籍/Nationality:              JPN\n"
              "生年月日/Date of Birth:        05/04/1965\n"
              "在留資格/Status of Residence:  Temporary Visitor\n"
              "上陸年月日/Date of Landing:    05/03/2018\n"
              "旅券等の種類/Passport etc.:    Passport\n"
              "番号/No.:                      TE5185785\n"
              "\n"
              "販売者氏名・名称/Seller's Name: THE STORE\n"
              "納税地/Place of Tax Payment:    東京都新宿区新宿X-X-X\n"
              "所轄税務署/Tax office concerned:新宿税務署\n"];
    IF_ERROR_COMPLETION
    
    // date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(skinManager.language == ePOSLanguageJapanese ) {
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ja_JP"]];
    } else {
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    }
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSDate *date = [NSDate date];
    NSString *dateString = [formatter stringFromDate:date];
    result = [agent addText:[NSString stringWithFormat:@"購入年月日/Date of Purchase:    %@\n",dateString]];
    IF_ERROR_COMPLETION
    
    result = [agent addText:@"\n"
              "購入した消耗品および一般物品の内訳明細および金額を添付します。\n"
              "消耗品/Consumable Commodities\n"
              "　合計金額(税抜)/Total amount without tax: ￥0\n"
              "　免税額/Exemption amount:                 ￥0\n"
              "_______________________________________________________\n"
              "一般物品(消耗品を除く)/Commodities except consumables\n"];
    IF_ERROR_COMPLETION
    
    result = [agent addText: [NSString stringWithFormat:@"　合計金額(税抜)/Total amount without tax:%@ \n",netForTaxFree]];
    IF_ERROR_COMPLETION
    
    result = [agent addText: [NSString stringWithFormat:@"　免税額/Exemption amount:                 %@\n",taxForTaxFree]];
    IF_ERROR_COMPLETION
    
    result = [agent addText:@"_______________________________________________________\n"];
    IF_ERROR_COMPLETION
    
    result = [agent addCut:EPOS2_CUT_FEED];
    IF_ERROR_COMPLETION
              
              
    //購入者誓約書------------------------------------
    static unsigned char cmdEscpos7[] = {0x1b,0x52,0x08,0x1b,0x74,0x01,0x1c,0x43,0x01,0x1b,0x2d,0x01,0x1c,0x2d,0x01,0x1b,0x61,0x01,0x1c,0x45,0x01,0x1b,0x20,0x01,0x1c,0x53,0x00,0x01,0x1b,0x33,0x22};
    NSData *data7 = [[NSData alloc] initWithBytes:cmdEscpos7 length:sizeof(cmdEscpos7)];
    result = [agent addCommand:data7];
    IF_ERROR_COMPLETION
    
    result = [agent addText:@"最終的に輸出となる物品の消費税免税購入に\n"
              "ついての購入者誓約書\n"
              "Covenant of Purchaser of Consumption\n"
              " Tax-Exempt of Ultimate Export\n"];
    IF_ERROR_COMPLETION
    
    static unsigned char cmdEscpos8[] = {0x1b,0x4d,0x31,0x1b,0x2d,0x00,0x1c,0x2d,0x00,0x1b,0x61,0x00,0x1c,0x45,0x00,0x1b,0x20,0x00,0x1c,0x53,0x00,0x00};
    NSData *data8 = [[NSData alloc] initWithBytes:cmdEscpos8 length:sizeof(cmdEscpos8)];
    result = [agent addCommand:data8];
    IF_ERROR_COMPLETION
    
    static unsigned char cmdEscpos9[] = {0x1c,0x28,0x41,0x02,0x00,0x30,0x01,0x1b,0x33,0x22};
    NSData *data9 = [[NSData alloc] initWithBytes:cmdEscpos9 length:sizeof(cmdEscpos9)];
    result = [agent addCommand:data9];
    IF_ERROR_COMPLETION
    
    result = [agent addText:@"・当該消耗品を、購入した日から30日以内に輸出されるものと\n"
              "  して購入し、日本で処分しないことを誓約します。\n"
              "  I certify that the goods listed as“consumable \n"
              "  commodities”on this card were purchased by me for\n"
              "  export from Japan within 30days from the purchase\n"
              "  date and will not be disposed of within Japan.\n"
              "・当該一般物品を、日本から最終的には輸出されるものとして\n"
              "  購入し、日本で処分しないことを誓約します。\n"
              "  I certify that the goods listed as“commodities \n"
              "  except consumables”on this card were purchased by me\n"
              "  for ultimate export from Japan and will not be\n"
              "  disposed of within Japan.\n"
              "\n"
              "署名/Signature\n"
              "\n"
              "\n"
              "\n"
              "_______________________________________________________"
              "\n"
              "購入者氏名/Name in full:       SHINJUKU TARO\n"
              "国籍/Nationality:              JPN\n"
              "生年月日/Date of Birth:        05/04/1965\n"
              "在留資格/Status of Residence:  Temporary Visitor\n"
              "上陸年月日/Date of Landing:    05/03/2018\n"
              "旅券等の種類/Passport etc.:    Passport\n"
              "番号/No.:                      TE5185785\n"
              "\n"
              "販売者氏名・名称/Seller's Name: THE STORE\n"];
      IF_ERROR_COMPLETION
    
    result = [agent addText:[NSString stringWithFormat:@"購入年月日/Date of Purchase:    %@\n",dateString]];
    IF_ERROR_COMPLETION
    
    result = [agent addText:@"\n"
              "購入した消耗品および一般物品の内訳明細および金額を添付します。\n"
              "消耗品/Consumable Commodities\n"
              "　合計金額(税抜)/Total amount without tax: ￥0\n"
              "　免税額/Exemption amount:                 ￥0\n"
              "_______________________________________________________\n"
              "一般物品(消耗品を除く)/Commodities except consumables\n"];
    IF_ERROR_COMPLETION
              
    result = [agent addText: [NSString stringWithFormat:@"　合計金額(税抜)/Total amount without tax:%@ \n",netForTaxFree]];
    IF_ERROR_COMPLETION
    
    result = [agent addText: [NSString stringWithFormat:@"　免税額/Exemption amount:                 %@\n",taxForTaxFree]];
    IF_ERROR_COMPLETION
    
    result = [agent addText:@"_______________________________________________________\n"];
    IF_ERROR_COMPLETION
    result = [agent addCut:EPOS2_CUT_FEED];
    IF_ERROR_COMPLETION
    
    result = [agent sendData];
    IF_ERROR_COMPLETION
    
}
// Add end 2018/3/1

#pragma mark - private

- (NSString *)makeItemName:(NSString *)name qty:(NSInteger)qty amount:(NSString *)amount
{
#if 1

    NSInteger max = [self maxLength];     // 70: 34,48   /  88: 30, 42
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    NSString *qtyString;
    qtyString = [NSString stringWithFormat:EPOSLocalizedString(@"QTYSTRING", skinManager.language, nil), qty];
    
    NSMutableString *resultString = [NSMutableString stringWithFormat:@"   %@",name];
    NSInteger len = [self lengthOfString:resultString isLarge:NO];
    
    for(NSInteger i = len ; i < [self qtyPostion] ; i++) {
        [resultString appendString:@" "];
    }
    [resultString appendString:qtyString];
    len = [self lengthOfString:resultString isLarge:NO];
    NSInteger count = (max - CHARCTER_MARGIN) - ( len + [self lengthOfString:amount isLarge:NO]);
    for(NSInteger i = len ; i < len + count ; i++) {
        [resultString appendString:@" "];
    }
    [resultString appendString:amount];
    
    NSInteger margin = max - [self lengthOfString:resultString isLarge:NO];
    
    if(margin > 1) {
        margin /= 2;
        for(NSInteger sp = 0 ; sp < margin ; sp++) {
            [resultString insertString:@" " atIndex:0];
        }
    }
    
    DEBUG_LOG(@"[%@]", resultString);
    
    return resultString;

#else
    NSInteger max = [self maxLength];     // 70: 34,48   /  88: 30, 42
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    NSString *qtyString;
    qtyString = [NSString stringWithFormat:EPOSLocalizedString(@"QTYSTRING", skinManager.language, nil), qty];

    NSMutableString *resultString = [NSMutableString stringWithFormat:@"   %@",name];   // <<< CHARCTER_MARGIN
    NSInteger len = [self lengthOfString:resultString isLarge:NO];
    for(NSInteger i = len ; i < [self qtyPostion] ; i++) {
        [resultString appendString:@" "];
    }
    [resultString appendString:qtyString];
    len = [self lengthOfString:resultString isLarge:NO];
    NSInteger count = (max - CHARCTER_MARGIN) - ( len + [self lengthOfString:amount isLarge:NO]);
    for(NSInteger i = len ; i < len + count ; i++) {
        [resultString appendString:@" "];
    }
    [resultString appendString:amount];
    DEBUG_LOG(@"[%@]", resultString);
    
    return resultString;
#endif
}


- (int)printTotal:(NSString *)item isItemLarge:(BOOL)isItemLarge value:(NSString *)value isValueLarge:(BOOL)isValueLarge space:(NSInteger)space
{
    ePOSAgent *agent = [ePOSAgent sharedAgent];

    int result;
    result = [agent addTextAlign:EPOS2_ALIGN_LEFT];
    IF_ERROR_RETURN
    
    if(isItemLarge) {
        result = [agent addTextSize:2 Height:1];
        IF_ERROR_RETURN
        
    } else {
        result = [agent addTextSize:1 Height:1];
        IF_ERROR_RETURN
        
    }
    NSString *taxString = item;
    result = [agent addText:taxString];
    IF_ERROR_RETURN

    result = [agent addTextSize:1 Height:1];
    IF_ERROR_RETURN
    
    NSMutableString *filler = [NSMutableString string];
    NSInteger len = [self lengthOfString:taxString isLarge:isItemLarge];
    NSString *total = value;
    NSInteger numberLength = [self lengthOfString:total isLarge:isValueLarge];
    NSInteger max = [self maxLength] - numberLength - space;
    for(NSInteger i = len ; i < max ; i++) {
        [filler appendString:@" "];
    }
    result = [agent addText:filler];
    IF_ERROR_RETURN
    
    if(isValueLarge) {
        result = [agent addTextSize:2 Height:1];
        IF_ERROR_RETURN
        
    } else {
        result = [agent addTextSize:1 Height:1];
        IF_ERROR_RETURN
        
    }
    result = [agent addText:total];
    IF_ERROR_RETURN
    
    
    result = [agent addFeed];
    IF_ERROR_RETURN
    
    return result;

}

- (NSInteger)lengthOfString:(NSString *)string isLarge:(BOOL)isLarge
{
    NSUInteger result = 0;
    unichar buffer[100];
    
    NSInteger count = isLarge ? 2 : 1;
    for(NSUInteger i = 0 ; i < string.length ; i++) {
        [string getCharacters:buffer range:NSMakeRange(i, 1)];
        if(buffer[0] < 256) {
            result += count;
        } else {
            result += count;
            result += count;
        }
    }
    
    return result;
}

- (void)printBarcode:(NSDictionary *)products completion:(ePosAgentPrintCompletionHandler)completion
{
    // debug.
#if 0
    NSMutableArray *keys = [NSMutableArray arrayWithArray:products.allKeys];
    [keys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    for(NSString *key in keys) {
        @autoreleasepool {
            NSDictionary *dict = products[key];
            
            UIImage *image = [self loadImage:dict[ePOSDataProductImageKey]];
        }
    }

#else
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    //ePOSItemManager *itemManager = [ePOSItemManager sharedItemManager];
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    
    [agent startPrintCompletion:^(Epos2Printer* printerObj,int code, Epos2PrinterStatusInfo* status, NSString* printJobId){
        if(completion) completion(printerObj, code, status, printJobId);
    }];
    
    int result = EPOS2_SUCCESS;
    
    result = [agent clearCommandBuffer];
    IF_ERROR_COMPLETION
    
    // Language
    if(skinManager.language == ePOSLanguageJapanese ) {
        result = [agent addTextLang:EPOS2_LANG_JA];
    } else {
        result = [agent addTextLang:EPOS2_LANG_EN];
    }
    IF_ERROR_COMPLETION

    NSMutableArray *keys = [NSMutableArray arrayWithArray:products.allKeys];
    [keys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];

    NSString *nameKey;
    if(skinManager.language == ePOSLanguageJapanese ) {
        nameKey = ePOSDataNameJapaneseKey;
    } else {
        nameKey = ePOSDataNameEnglishKey;
    }
    for(NSString *key in keys) {
        @autoreleasepool {
            NSDictionary *dict = products[key];
        
            result = [agent addTextAlign:EPOS2_ALIGN_CENTER];
            IF_ERROR_COMPLETION

            UIImage *image = [self loadImage:dict[ePOSDataProductImageKey]];
            if(image) {
                CGFloat scale = image.size.width / 180.;
                UIImage *printImage = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];

                result = [agent addImage:printImage X:0 Y:0 Width:(long)printImage.size.width Height:(long)printImage.size.height
                               Color:EPOS2_COLOR_1 Mode:EPOS2_MODE_MONO];
                IF_ERROR_COMPLETION

                result = [agent addFeed];
                IF_ERROR_COMPLETION
            }

            result = [agent addText:dict[nameKey]];
            IF_ERROR_COMPLETION
            
            result = [agent addFeed];
            IF_ERROR_COMPLETION

            result = [agent addBarcode:key Type:EPOS2_BARCODE_CODE39 Hri:EPOS2_HRI_BELOW Font:EPOS2_FONT_A Width:2 Height:35];
            IF_ERROR_COMPLETION

            result = [agent addFeed];
            IF_ERROR_COMPLETION
        }
    }
    
    result = [agent addCut:EPOS2_CUT_FEED];
    IF_ERROR_COMPLETION
    
    result = [agent sendData];
    IF_ERROR_COMPLETION
#endif
    
}

- (UIImage *)loadImage:(NSString *)imageName
{
    UIImage *image = nil;
    if(imageName.length) {
        NSArray *documentPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = documentPathList.lastObject;
        NSString *imageFolderPath = [documentPath stringByAppendingPathComponent:@"images"];
        NSString *imagePath = [imageFolderPath stringByAppendingPathComponent:imageName];
        image = [UIImage imageWithContentsOfFile:imagePath];
        if(image == nil) {
            NSString *fileName = [[imageName lastPathComponent] stringByDeletingPathExtension];
            NSString *extension = [imageName pathExtension];
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    return image;
}


- (NSInteger)maxLength
{
    //NSInteger max = 42;     // 70: 34,48   /  88: 30, 42
    NSInteger max = [[[NSUserDefaults standardUserDefaults] objectForKey:ePOSDefaultPrintColumnKey] integerValue];
    return max;
}

- (NSInteger)qtyPostion
{
    NSInteger col = [[[NSUserDefaults standardUserDefaults] objectForKey:ePOSDefaultPrintColumnKey] integerValue];
    if(col == 48) {
        return 27;
    } else if(col == 42) {
        return 23;
    } else if(col == 35) {
        return 18;      // 27
    } else if(col == 34) {
        return 18;      // 27
    } else if(col == 30) {
        return 14;      // 27
    }
    return 20;
}

- (NSInteger)maxWidth
{
    return 500;
}


@end




