//
//  ePOSItemManager.m
//  ePOS
//
//  Created by komatsu on 2014/06/25.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSItemManager.h"
#import "ePOSSkinManager.h"
#import "ePOSDataManager.h"
#import "ePOSUserDefault.h"

#define EPOS_TAX (1.08)

NSString * const ePOSItemProductCodeKey                 = @"ePOSItemProductCodeKey";
NSString * const ePOSItemQuantityKey                    = @"ePOSItemQuantityKey";


static ePOSItemManager *_itemManager = nil;

@implementation ePOSItemManager
{
    ePOSSkinManager *_skinManager;
    ePOSDataManager *_dataManager;
    NSMutableArray *_itemList;
    NSInteger _deposit;
}

+ (ePOSItemManager *)sharedItemManager
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _itemManager = [[ePOSItemManager alloc] init];
    });
    return _itemManager;
    
}

- (NSInteger)count
{
    return _itemList.count;
}

- (void)addItemCode:(NSString *)productCode quantity:(NSInteger)quantity
{
    if(productCode.length) {
        NSDictionary *dict = nil;
        NSInteger index = 0;
        for(NSDictionary *itemDict in _itemList) {
            NSString *code = itemDict[ePOSItemProductCodeKey];
            if([productCode isEqualToString:code]) {
                NSInteger orignalQty = [itemDict[ePOSItemQuantityKey] integerValue];
                NSInteger qty = quantity + orignalQty;
                if(qty > 99) {
                    qty = 99;   // ??
                }
                dict = @{ePOSItemProductCodeKey : productCode,
                         ePOSItemQuantityKey    : @(qty)};
                break;
            }
            index++;
        }
        if(dict == nil) {
            dict = @{ePOSItemProductCodeKey   : productCode,
                     ePOSItemQuantityKey      : @(quantity)};
            [_itemList addObject:dict];
        } else {
            [_itemList replaceObjectAtIndex:index withObject:dict];
        }
    }
}

- (void)updateIndex:(NSInteger)index increment:(BOOL)incrimet
{
    if(index < _itemList.count) {
        NSDictionary *dict = _itemList[index];
        NSInteger quantity = [dict[ePOSItemQuantityKey] integerValue];
        if(incrimet) {
            if(quantity <= 98) {
                quantity ++;
            }
        } else {
            if(quantity > 1) {
                quantity --;
            }
        }
        NSDictionary *newDict = @{ePOSItemProductCodeKey   : dict[ePOSItemProductCodeKey],
                                  ePOSItemQuantityKey      : @(quantity)};
        
        [_itemList replaceObjectAtIndex:index withObject:newDict];
    }
}

- (NSString *)nameAtIndex:(NSInteger)index
{
    NSString *name = nil;
    NSDictionary *dict = [self itemAtIndex:index];
    if(dict) {
        NSString *code = dict[ePOSItemProductCodeKey];
        name = [_dataManager nameFromCode:code];
    }
    return name;
}

- (NSString *)phoneticAtIndex:(NSInteger)index
{
    NSString *name = nil;
    NSDictionary *dict = [self itemAtIndex:index];
    if(dict) {
        NSString *code = dict[ePOSItemProductCodeKey];
        name = [_dataManager phoneticFromCode:code];
    }
    return name;
}

- (NSString *)priceAtIndex:(NSInteger)index
{
    NSString *price = @"";
    NSDictionary *dict = [self itemAtIndex:index];
    if(dict) {
        NSString *code = dict[ePOSItemProductCodeKey];

        NSNumberFormatter *formatter = [self numberFormatter];
        price = [formatter stringFromNumber:@([_dataManager priceFromCode:code])];
    }
    return price;

}
- (NSString *)phoneticPriceAtIndex:(NSInteger)index
{
    NSString *string = [self priceAtIndex:index];
    if(_skinManager.language == ePOSLanguageEnglish) {
        return string;
    } else {
        NSArray *strs = [string componentsSeparatedByString:@"¥"];
        return string;//[@"\\" stringByAppendingString:strs[1]];
    }

}

- (NSString *)amountAtIndex:(NSInteger)index
{
    NSString *amount = @"";
    NSDictionary *dict = [self itemAtIndex:index];
    if(dict) {
        NSInteger quantity = [dict[ePOSItemQuantityKey] integerValue];
        NSString *code = dict[ePOSItemProductCodeKey];
        double price = [_dataManager priceFromCode:code];
        
        NSNumberFormatter *formatter = [self numberFormatter];
        amount = [formatter stringFromNumber:@(price * quantity)];
        
    }
    return amount;
    
}

- (NSInteger)quantityAtIndex:(NSInteger)index
{
    NSInteger quantity = 0;
    NSDictionary *dict = [self itemAtIndex:index];
    if(dict) {
        quantity = [dict[ePOSItemQuantityKey] integerValue];
    }
    return quantity;
}

- (void)removeItemAtIndex:(NSInteger)index
{
    if(_itemList.count > index) {
        [_itemList removeObjectAtIndex:index];
    }
}

- (void)removeAllItems
{
    [_itemList removeAllObjects];
}

// 税抜き
- (NSString *)net
{
    NSNumberFormatter *formatter = [self numberFormatter];
    return [formatter stringFromNumber:@([self netInteger])];
}

- (NSString *)phoneticNet
{
    NSString *string = self.net;
    if(_skinManager.language == ePOSLanguageEnglish) {
        return string;
    } else {
        NSArray *strs = [string componentsSeparatedByString:@"￥"];
        return string;//[@"\\" stringByAppendingString:strs[0]];
    }
}

// 税金
- (NSString *)tax
{
    double tax = [self totalLong] - [self netInteger];
    NSNumberFormatter *formatter = [self numberFormatter];
    return [formatter stringFromNumber:@(tax)];
}

- (NSString *)phoneticTax
{
    NSString *string = self.tax;
    if(_skinManager.language == ePOSLanguageEnglish) {
        return string;
    } else {
        NSArray *strs = [string componentsSeparatedByString:@"￥"];
        return string;//[@"\\" stringByAppendingString:strs[0]];
    }
}


// 税込み
- (NSString *)total
{
    double total = [self totalLong];
    NSNumberFormatter *formatter = [self numberFormatter];
    return [formatter stringFromNumber:@(total)];
}

- (NSString *)phoneticTotal
{
    NSString *string = self.total;
    if(_skinManager.language == ePOSLanguageEnglish) {
        return string;
    } else {
        NSArray *strs = [string componentsSeparatedByString:@"￥"];
        return string;//[@"\\" stringByAppendingString:strs[0]];
    }
}

- (NSString *)deposit
{
    NSNumberFormatter *formatter = [self numberFormatter];
    return [formatter stringFromNumber:@(_depositValue)];
}

- (NSString *)change
{
    double change = 0;
    if(_depositValue != 0) {
        change = self.depositValue - [self totalLong];
    }
    NSNumberFormatter *formatter = [self numberFormatter];
    return [formatter stringFromNumber:@(change)];
}

- (NSString *)phoneticDeposit
{
    NSString *string = self.deposit;
    if(_skinManager.language == ePOSLanguageEnglish) {
        return string;
    } else {
        //NSArray *strs = [string componentsSeparatedByString:@"￥"];
        //return [@"\\" stringByAppendingString:strs[0]];
        return string;
    }
}

- (NSString *)phoneticChange
{
    NSString *string = self.change;
    if(_skinManager.language == ePOSLanguageEnglish) {
        return string;
    } else {
        //NSArray *strs = [string componentsSeparatedByString:@"￥"];
        return string;//[@"\\" stringByAppendingString:strs[0]];
        
    }
}

- (BOOL)isSufficient
{
    return [self totalLong] <= self.depositValue ? YES : NO;
}

- (BOOL)checkDeposit
{
    BOOL result = NO;
    if(self.depositValue == 0) {
        self.depositValue = [self totalLong];
        result = YES;
    }
    return result;
}

#pragma mark - private
- (id)init
{
    self = [super init];
    if (self) {
        _skinManager = [ePOSSkinManager sharedSkinManager];
        _dataManager = [ePOSDataManager sharedDataManager];
        _itemList = [NSMutableArray array];
        _deposit = 0;
        [self makeReportsFolder];
    }
    return self;
}

- (NSDictionary *)itemAtIndex:(NSInteger)index
{
    if(_itemList.count > index) {
        return _itemList[index];
    }
    return  nil;
}

- (NSNumberFormatter *)numberFormatter
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    if(_skinManager.language == ePOSLanguageEnglish) {
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    } else {
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    }
    return formatter;
}

- (double)totalLong
{
    double total = 0;
    for(NSDictionary *dict in _itemList) {
        double quantity = [dict[ePOSItemQuantityKey] integerValue];
        NSString *code = dict[ePOSItemProductCodeKey];
        double price = [_dataManager priceFromCode:code];
        total += price * quantity;
    }
    return total;
}

- (NSInteger)netInteger
{
    return round([self totalLong] / EPOS_TAX);
}

- (void)updateCheckNumber
{
    NSInteger number = self.currentCheckNumber;
    number = number + 1;
    
    if(number > 9999) {
        number = 1;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(number) forKey:ePOSDefaultCheckNumberKey];

}

- (NSInteger)currentCheckNumber
{
    NSArray *csvPaths = [self makeCSVPath];
    NSString *csvPath = csvPaths[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSNumber *number = @(1);
    if([fileManager fileExistsAtPath:csvPath]) {
        number = [[NSUserDefaults standardUserDefaults] objectForKey:ePOSDefaultCheckNumberKey];
        if(number == nil) {
            number = @(1);
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:number forKey:ePOSDefaultCheckNumberKey];
    return number.integerValue;
}

- (void)addCSV:(NSArray *)sign
{
    NSString *recordString = [self makeRecord:sign];
    NSString *detailString = [self makeDetail];
    [self updateCheckNumber];
    NSArray *csvPaths = [self makeCSVPath];

    NSData *data = [NSData dataWithContentsOfFile:csvPaths[0]];
    NSMutableData *newData = [NSMutableData dataWithData:data];
    [newData appendData:[recordString dataUsingEncoding:NSUTF8StringEncoding]];
    [newData writeToFile:csvPaths[0] atomically:YES];


    NSData *data2 = [NSData dataWithContentsOfFile:csvPaths[1]];
    NSMutableData *newData2 = [NSMutableData dataWithData:data2];
    [newData2 appendData:[detailString dataUsingEncoding:NSUTF8StringEncoding]];
    [newData2 writeToFile:csvPaths[1] atomically:YES];
}

/*
 ■取引CSV
 通し番号, 日付時間, サイン名称.png,税抜,税金,預り金額,合計,釣り,通貨単位
 
 ■詳細取引CSV
 通し番号,行番号,商品,単価,個数
 
 イメージとしては
 
 ■取引CSV
 "1","2014.08.08.13:33:43","001.png","14.5","0.5","20"."5","$"
 "2","2014.08.08.13:50:43","002.png","4","0.1","5"."0.9","$"
 
 ■詳細取引CSV
 "1","1,1000000001020","5","2"
 "1","2,1000000001021","4.5","1"
 "2","1,1000000001023","4","1"
 
*/

- (NSString *)makeRecord:(NSArray *)sign
{
    NSMutableString *recordString = [NSMutableString string];
    
    // serial number
    [recordString appendString:[NSString stringWithFormat:@"\"%04zi\",", self.currentCheckNumber]];
    
    // date & time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"\"yyyy.MM.dd.HH:mm:ss\",";
    NSDate *date = [NSDate date];
    [recordString appendString:[dateFormatter stringFromDate:date]];
    dateFormatter.dateFormat = @"yyyy-mm-dd-HH-mm-ss";

    NSString *signPath = [self signPath:date];
    
    NSString *signName = @"";
    if(sign != nil) {
        [self saveSign:sign name:signPath];
        signName = [signPath lastPathComponent];
    }
    
    NSString *currency;
    if(_skinManager.language == ePOSLanguageEnglish) {
        currency = @"$";
    } else {
        currency = @"\\";
    }

    // net
    double tax = [self totalLong] - [self netInteger];
    NSInteger change = 0;
    if(_depositValue != 0) {
        change = self.depositValue - [self totalLong];
    }

    [recordString appendString:[NSString stringWithFormat:@"\"%@\",\"%zi\",\"%0.2f\",\"%0.2f\",\"%0.2f\",\"%zi\",\"%@\"",
                                signName, [self netInteger], tax, [self totalLong], _depositValue, change, currency]];
    
//    for(NSDictionary *dict in _itemList) {
//        [recordString appendString:[NSString stringWithFormat:@",\"%@\",%@", dict[ePOSItemProductCodeKey], dict[ePOSItemQuantityKey]]];
//    }
    [recordString appendString:@"\n"];
    
    DEBUG_LOG(@"[%@]", recordString);
    
    return recordString;
}

- (NSString *)makeDetail
{
    NSMutableString *recordString = [NSMutableString string];

    NSInteger line = 1;
    for(NSDictionary *dict in _itemList) {
        NSString *codeKey = dict[ePOSItemProductCodeKey];
        [recordString appendString:[NSString stringWithFormat:@"\"%04zi\",\"%zi\",\"%@\",%@, %0.2f\n",
                                    self.currentCheckNumber, line, codeKey, dict[ePOSItemQuantityKey], [_dataManager priceFromCode:codeKey]]];
        line ++;
    }
    
    return recordString;
}

- (NSArray *)makeCSVPath
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *name = [NSString stringWithFormat:@"Reports/Reports-%@.csv", dateString];
    NSString *detailName = [NSString stringWithFormat:@"Reports/Details-%@.csv", dateString];
    
    NSArray *documentPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentPathList.lastObject;

    NSString *csvPath = [documentPath stringByAppendingPathComponent:name];
    NSString *csvPath2 = [documentPath stringByAppendingPathComponent:detailName];
    return @[csvPath, csvPath2];
}

- (void)makeReportsFolder
{
    NSArray *documentPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentPathList.lastObject;
    
    NSString *reportsPath = [documentPath stringByAppendingPathComponent:@"Reports"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:reportsPath]) {
        NSError *error;
        [fileManager createDirectoryAtPath:reportsPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *signPath = [reportsPath stringByAppendingPathComponent:@"Sign"];
    if(![fileManager fileExistsAtPath:signPath]) {
        NSError *error;
        [fileManager createDirectoryAtPath:signPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

- (NSString *)signPath:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-mm-dd-HH-mm-ss";
    NSString *signName = [[dateFormatter stringFromDate:date] stringByAppendingPathExtension:@"png"];
    NSArray *documentPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentPathList.lastObject;
    NSString *path = [documentPath stringByAppendingPathComponent:@"Reports/Sign"];
    path = [path stringByAppendingPathComponent:signName];
    return path;
}

- (void)saveSign:(NSArray *)sign name:(NSString *)name
{
    if(name.length) {
        UIImage *image = [self createSign:sign width:700];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:name atomically:YES];
    }
}

- (UIImage *)createSign:(NSArray *)sign width:(NSInteger)width
{
    CGSize orginalSize = CGSizeMake(700., 400.);
    NSInteger contextWidth = width;
    CGFloat scale = contextWidth / orginalSize.width;
    NSInteger contextHeight = orginalSize.height * scale;
    
    CGFloat lineWidth = 4.;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(NULL, contextWidth, contextHeight, 8, contextWidth, colorSpace, 0);
    CGColorSpaceRelease(colorSpace);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -contextHeight);
    
    CGContextSetRGBFillColor(context, 1.,1.,1.,1.);
    CGContextFillRect(context, CGRectMake(0., 0., contextWidth, contextHeight));
    
    //    CGContextSetRGBFillColor(context, 0.,0.,0.,1.);
    //    CGContextStrokeRect(context, CGRectMake(3., 3., contextWidth-6, contextHeight-6));
    
    UIGraphicsPushContext(context);
    
    CGContextSetAllowsAntialiasing(context, FALSE);
    CGContextSetShouldAntialias(context, FALSE);
    
    CGContextScaleCTM(context, scale, scale);
    
    for ( NSDictionary *contentDict in sign )
    {
        UIBezierPath *bezierPath = contentDict[@"DrawBezierPathKey"];
        bezierPath.lineWidth = lineWidth;
        bezierPath.lineCapStyle = kCGLineCapRound;
        bezierPath.lineJoinStyle = kCGLineJoinRound;
        [bezierPath stroke];
    }
    
    UIGraphicsPopContext();
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *image = [UIImage imageWithCGImage:cgimage];
    CGImageRelease(cgimage);
    
    return image;
}

@end
