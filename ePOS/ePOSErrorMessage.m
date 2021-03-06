//
//  ePOSErrorMessage.m
//  ePOS
//
//  Created by komatsu on 2014/07/20.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSErrorMessage.h"
#import "ePOSSkinManager.h"
#import "ePOS2.h"

@implementation ePOSErrorMessage

+ (NSString *)message:(int)errorCode;
{
    NSString *result = nil;
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    
    switch (errorCode) {
//        case EDEV_OC_SUCCESS:
//            break;
//
//        case EDEV_OC_ERR_AUTOMATICAL:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_AUTOMATICAL", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_COVER_OPEN:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_COVER_OPEN", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_CUTTER:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_CUTTER", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_MECHANICAL:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_MECHANICAL", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_EMPTY:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_EMPTY", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_UNRECOVERABLE:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_UNRECOVERABLE", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_FAILURE:
//            //result = EPOSLocalizedString(@"EDEV_OC_ERR_FAILURE", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_SYSTEM:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_SYSTEM", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_PORT:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_PORT", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_TIMEOUT:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_TIMEOUT", skinManager.language, nil);
//            break;
//
//        case EDEV_OC_ERR_IN_USE:
//            result = EPOSLocalizedString(@"EDEV_OC_ERR_IN_USE", skinManager.language, nil);
//            break;
            
        case -1:
            result = EPOSLocalizedString(@"NotConnected", skinManager.language, nil);
            break;
            
        default:
            result = EPOSLocalizedString(@"UnexpectedError", skinManager.language, nil);
            break;
    }
    
    if(result) {
        result = [NSString stringWithFormat:@"%@(%i)", result, errorCode];
    }
    return result;
    
}
@end
