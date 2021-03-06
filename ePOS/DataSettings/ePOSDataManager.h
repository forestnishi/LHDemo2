//
//  ePOSDataManager.h
//  ePOS
//
//  Created by komatsu on 2014/06/24.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ePOSDataNameEnglishKey;
extern NSString * const ePOSDataNameJapaneseKey;
extern NSString * const ePOSDataNamePhoneticEnglishKey;
extern NSString * const ePOSDataNamePhoneticJapanesehKey;
extern NSString * const ePOSDataPriceKey;
extern NSString * const ePOSDataProductImageKey;

@interface ePOSDataManager : NSObject

+ (ePOSDataManager *)sharedDataManager;

- (NSDictionary *)dictionaryFromCode:(NSString *)productCode;
- (NSString *)nameEnglishFromCode:(NSString *)productCode;
- (NSString *)nameJapaneseFromCode:(NSString *)productCode;
- (NSString *)nameFromCode:(NSString *)productCode;
- (NSString *)phoneticFromCode:(NSString *)productCode;
- (NSString *)phoneticEnglishFromCode:(NSString *)productCode;
- (NSString *)phoneticJapaneseFromCode:(NSString *)productCode;
- (double)priceFromCode:(NSString *)productCode;

- (NSString *)randomCode;

- (BOOL)setCurrentData;

@end
