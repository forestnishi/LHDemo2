//
//  ePOSItemManager.h
//  ePOS
//
//  Created by komatsu on 2014/06/25.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ePOSItemManager : NSObject

+ (ePOSItemManager *)sharedItemManager;

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSString *net;
@property (nonatomic, readonly) NSString *tax;
@property (nonatomic, readonly) NSString *total;
@property (nonatomic, readonly) NSString *phoneticTotal;
@property (nonatomic, readonly) NSString *deposit;
@property (nonatomic, readonly) NSString *change;
@property (nonatomic, readonly) NSString *phoneticDeposit;
@property (nonatomic, readonly) NSString *phoneticChange;


@property (nonatomic) double depositValue;
@property (nonatomic) NSInteger currentQuantity;

@property (nonatomic, readonly) NSInteger currentCheckNumber;

- (NSString *)nameAtIndex:(NSInteger)index;
- (NSString *)phoneticAtIndex:(NSInteger)index;
- (NSString *)priceAtIndex:(NSInteger)index;
- (NSString *)phoneticPriceAtIndex:(NSInteger)index;
- (NSString *)amountAtIndex:(NSInteger)index;
- (NSInteger)quantityAtIndex:(NSInteger)index;
- (void)removeItemAtIndex:(NSInteger)index;
- (void)removeAllItems;
- (BOOL)isSufficient;
- (BOOL)checkDeposit;

- (void)addItemCode:(NSString *)productCode quantity:(NSInteger)quantity;
- (void)updateIndex:(NSInteger)index increment:(BOOL)incrimet;

- (void)addCSV:(NSArray *)sign;

- (UIImage *)createSign:(NSArray *)sign width:(NSInteger)width;

@end
