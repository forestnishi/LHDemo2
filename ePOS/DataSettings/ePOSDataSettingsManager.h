//
//  ePOSDataSettingsManager.h
//  ePOS
//
//  Created by komatsu on 2014/07/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ePOSDataSettingsManager : NSObject

@property (nonatomic, readonly) NSInteger fileCount;

- (NSString *)fileNameAtIndex:(NSInteger)index;
- (NSString *)filePathAtIndex:(NSInteger)index;
- (NSDictionary *)dictionaryAtIndex:(NSInteger)index;
- (void)removeObjectAtIndex:(NSInteger)index;
- (void)writeObjectAtIndex:(NSDictionary *)dictionary atIndex:(NSInteger)index;
- (NSString *)containsFileNmae:(NSString *)name;

@end
