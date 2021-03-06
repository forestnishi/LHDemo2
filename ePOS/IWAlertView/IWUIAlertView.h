//
//  IWUIAlertView.h
//  WebLibSample
//
//  Created by komatsu on 2013/08/25.
//  Copyright (c) 2013年 iWare inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completionHandler)(NSInteger buttonIndex);
typedef void (^completionTextInputHandler)(NSInteger buttonIndex, NSString *text);
typedef void (^completionTextInputHandler2)(NSInteger buttonIndex, NSString *text, NSString *text2);

@interface IWUIAlertView : UIAlertView <UIAlertViewDelegate>

- (void)showWithCompletionHandler:(completionHandler)completionHandler;
- (void)showWithAlertStyle:(UIAlertViewStyle)style completion:(completionTextInputHandler)completionTextInputHandler;
- (void)showWithAlertStyle:(UIAlertViewStyle)style completion2:(completionTextInputHandler2)completionTextInputHandler2;

@end
