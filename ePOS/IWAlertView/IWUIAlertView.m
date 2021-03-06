//
//  IWUIAlertView.m
//  WebLibSample
//
//  Created by komatsu on 2013/08/25.
//  Copyright (c) 2013年 iWare inc. All rights reserved.
//

#import "IWUIAlertView.h"

@interface IWUIAlertView ()
{
    completionHandler _completionHandler;
    completionTextInputHandler _completionTextInputHandler;
    completionTextInputHandler2 _completionTextInputHandler2;
}
@end

@implementation IWUIAlertView

- (void)showWithCompletionHandler:(completionHandler)completionHandler;
{
    _completionHandler = completionHandler;
    _completionTextInputHandler = nil;
    _completionTextInputHandler2 = nil;
    self.delegate = self;
    
    [self show];
}

- (void)showWithAlertStyle:(UIAlertViewStyle)style completion:(completionTextInputHandler)completionTextInputHandler
{
    _completionHandler = nil;
    _completionTextInputHandler = completionTextInputHandler;
    _completionTextInputHandler2 = nil;
    self.alertViewStyle = style;
    self.delegate = self;
    
    [self show];
}

- (void)showWithAlertStyle:(UIAlertViewStyle)style completion2:(completionTextInputHandler2)completionTextInputHandler2
{
    _completionHandler = nil;
    _completionTextInputHandler = nil;
    _completionTextInputHandler2 = completionTextInputHandler2;
    self.alertViewStyle = style;
    self.delegate = self;
    
    [self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_completionHandler) {
        
        _completionHandler(buttonIndex);
    
    } else if(_completionTextInputHandler) {
    
        _completionTextInputHandler(buttonIndex, [alertView textFieldAtIndex:0].text);
    
    } else if(_completionTextInputHandler2) {
        
        _completionTextInputHandler2(buttonIndex, [alertView textFieldAtIndex:0].text, [alertView textFieldAtIndex:1].text);
    
    }
}

@end
