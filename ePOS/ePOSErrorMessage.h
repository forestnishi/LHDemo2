//
//  ePOSErrorMessage.h
//  ePOS
//
//  Created by komatsu on 2014/07/20.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ePOSErrorMessage : NSObject

+ (NSString *)message:(int)errorCode;

@end
