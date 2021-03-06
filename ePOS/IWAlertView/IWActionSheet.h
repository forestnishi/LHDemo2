//
//  IWActionSheet.h
//  WebLibSample
//
//  Created by komatsu on 2013/08/25.
//  Copyright (c) 2013年 iWare inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^completionBlock)(NSInteger buttonIndex);

@interface IWActionSheet : UIActionSheet <UIActionSheetDelegate>

- (void)showFromToolbar:(UIToolbar *)view withHandler:(completionBlock)completionHandler;
- (void)showFromTabBar:(UITabBar *)view withHandler:(completionBlock)completionHandler;
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated withHandler:(completionBlock)completionHandler;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated withHandler:(completionBlock)completionHandler;
- (void)showInView:(UIView *)view withHandler:(completionBlock)completionHandler;

@end
