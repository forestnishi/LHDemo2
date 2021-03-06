//
//  ePOSDataSettingsManager.m
//  ePOS
//
//  Created by komatsu on 2014/07/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSDataSettingsManager.h"

@implementation ePOSDataSettingsManager
{
    NSMutableArray *_files;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self readDatas];
    }
    return self;
}

- (NSInteger)fileCount
{
    return _files.count;
}
- (NSString *)filePathAtIndex:(NSInteger)index
{
    if(self.fileCount > index) {
        return _files[index];
    }
    return nil;
}

- (NSString *)fileNameAtIndex:(NSInteger)index
{
    NSString *path = [self filePathAtIndex:index];
    if(path) {
        return [path lastPathComponent];
    }
    return nil;
}

- (NSDictionary *)dictionaryAtIndex:(NSInteger)index
{
    NSString *path = [self filePathAtIndex:index];
    if(path) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        return dict;
    }
    return nil;
}

- (void)removeObjectAtIndex:(NSInteger)index
{
    NSString *path = [self filePathAtIndex:index];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:path error:&error];
    [self readDatas];
}

- (void)writeObjectAtIndex:(NSDictionary *)dictionary atIndex:(NSInteger)index
{
    NSString *path = [self filePathAtIndex:index];
    [self removeObjectAtIndex:index];
    
    [dictionary writeToFile:path atomically:YES];
    [self readDatas];

}

- (NSString *)containsFileNmae:(NSString *)name
{
    for(NSString *path in _files) {
        NSString *fileName = [path lastPathComponent];
        if([fileName isEqualToString:name]) {
            return path;
        }
    }
    return NO;
}

#pragma mark - Private
- (void)readDatas
{
    NSArray *documentPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentPathList.lastObject;
    
    _files = [NSMutableArray array];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentPath error:&error];

    NSString *presetPath = [documentPath stringByAppendingPathComponent:@"Preset.plist"];
    if([fileManager fileExistsAtPath:presetPath]) {
        [_files addObject:presetPath];
    }
    for(NSString *path in fileList) {
        if([path hasPrefix:@"product"]) {
            NSString *filePath = [documentPath stringByAppendingPathComponent:path];
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
            if(dict) {
                [_files addObject:[documentPath stringByAppendingPathComponent:path]];
            }
        }
    }
    DEBUG_LOG(@"%@", _files);
    
}
@end
