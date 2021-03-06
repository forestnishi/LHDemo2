//
//  ePOSPrintManager.h
//  ePOS
//
//  Created by komatsu on 2014/07/07.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ePOSAgent.h"

@interface ePOSPrintManager : NSObject{
}


- (void)printReceipt:(Boolean) memberID:(NSArray *)sign completion:(ePosAgentPrintCompletionHandler)completion;
- (void)printTaxFree:(NSString*)taxForTaxFree: (NSString*)netForTaxFree completion:(ePosAgentPrintCompletionHandler)completion;
- (void)printBarcode:(NSDictionary *)products completion:(ePosAgentPrintCompletionHandler)completion;

@end
