//
//  ePOSDataManager.m
//  ePOS
//
//  Created by komatsu on 2014/06/24.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#include "stdlib.h"

#import "ePOSDataManager.h"
#import "ePOSUserDefault.h"
#import "ePOSSkinManager.h"

NSString * const ePOSDataNameEnglishKey                 = @"name_en";
NSString * const ePOSDataNameJapaneseKey                = @"name_jp";
NSString * const ePOSDataNamePhoneticEnglishKey         = @"phonetic_en";
NSString * const ePOSDataNamePhoneticJapanesehKey       = @"phonetic_jp";
NSString * const ePOSDataPriceKey                       = @"price";
NSString * const ePOSDataProductImageKey                = @"product_image";

static ePOSDataManager *_dataManager = nil;

@implementation ePOSDataManager
{
    NSMutableDictionary *_currentData;
    ePOSSkinManager *_skinManager;
}

+ (ePOSDataManager *)sharedDataManager
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _dataManager = [[ePOSDataManager alloc] init];
    });
    return _dataManager;
    
}

- (NSDictionary *)dictionaryFromCode:(NSString *)productCode
{
    return _currentData[productCode];
}

- (NSString *)nameEnglishFromCode:(NSString *)productCode
{
    NSDictionary *dict = [self dictionaryFromCode:productCode];
    return dict[ePOSDataNameEnglishKey];
}

- (NSString *)nameJapaneseFromCode:(NSString *)productCode
{
    NSDictionary *dict = [self dictionaryFromCode:productCode];
    return dict[ePOSDataNameJapaneseKey];
}

- (NSString *)nameFromCode:(NSString *)productCode
{
    if(_skinManager.language == ePOSLanguageEnglish) {
        return [self nameEnglishFromCode:productCode];
    } else {
        return [self nameJapaneseFromCode:productCode];
    }
}

- (NSString *)phoneticFromCode:(NSString *)productCode
{
    if(_skinManager.language == ePOSLanguageEnglish) {
        return [self phoneticEnglishFromCode:productCode];
    } else {
        return [self phoneticJapaneseFromCode:productCode];
    }
}

- (NSString *)phoneticEnglishFromCode:(NSString *)productCode
{
    NSDictionary *dict = [self dictionaryFromCode:productCode];
    return dict[ePOSDataNamePhoneticEnglishKey];
}

- (NSString *)phoneticJapaneseFromCode:(NSString *)productCode
{
    NSDictionary *dict = [self dictionaryFromCode:productCode];
    NSString *result = nil;
    NSString *str = dict[ePOSDataNamePhoneticJapanesehKey];
    if(str) {
        NSMutableString *string = [NSMutableString stringWithString:str];
        CFStringTransform((__bridge CFMutableStringRef)string, NULL, kCFStringTransformFullwidthHalfwidth, false);
        result = [NSString stringWithString:string];
    }
    DEBUG_LOG(@"%@", result);
    return result;
}

- (double)priceFromCode:(NSString *)productCode
{
    NSDictionary *dict = [self dictionaryFromCode:productCode];
    double price = [dict[ePOSDataPriceKey] integerValue];
    if(_skinManager.language == ePOSLanguageEnglish) {
        price /= 100;
    }
    return price;

}

- (NSString *)randomCode
{
    NSString *code = nil;
    NSInteger index = arc4random() % _currentData.count;
    NSArray *array = [_currentData allKeys];
    return code = array[index];
}

- (BOOL)setCurrentData
{
    BOOL result = NO;
    NSDictionary *dict = nil;
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:ePOSCurrentProductFileKey];
    if(name) {
        NSArray *documentPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = documentPathList.lastObject;
        NSString *filePath = [documentPath stringByAppendingPathComponent:name];
        dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        if(dict == nil) {
            NSURL *plistUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Preset" ofType:@"plist"] isDirectory:NO];
            dict = [NSDictionary dictionaryWithContentsOfURL:plistUrl];
        }
    } else {
        NSURL *plistUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Preset" ofType:@"plist"] isDirectory:NO];
        dict = [NSDictionary dictionaryWithContentsOfURL:plistUrl];
    }
    
    if(![dict isEqualToDictionary:_currentData]) {
        result = YES;
    }
    _currentData = [NSMutableDictionary dictionaryWithDictionary:dict];
    DEBUG_LOG(@"%@", _currentData);
    
    return result;
}

#pragma mark - Private
- (id)init
{
    self = [super init];
    if (self) {
        _skinManager = [ePOSSkinManager sharedSkinManager];
        _currentData = nil;
        [self setCurrentData];
    }
    return self;
}

@end
