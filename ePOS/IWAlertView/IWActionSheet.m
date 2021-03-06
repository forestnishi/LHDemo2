//
//  IWActionSheet.m
//  WebLibSample
//
//  Created by komatsu on 2013/08/25.
//  Copyright (c) 2013年 iWare inc. All rights reserved.
//

#import "IWActionSheet.h"

@interface IWActionSheet ()
{
    completionBlock _completionBlock;
}
@end

@implementation IWActionSheet

- (void)showFromToolbar:(UIToolbar *)view withHandler:(completionBlock)completionBlock
{
    _completionBlock = completionBlock;
    self.delegate = self;
    
    [self showFromToolbar:view];
}

- (void)showFromTabBar:(UITabBar *)view withHandler:(completionBlock)completionBlock
{
    _completionBlock = completionBlock;
    self.delegate = self;
    
    [self showFromTabBar:view];
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated withHandler:(completionBlock)completionBlock
{
    _completionBlock = completionBlock;
    self.delegate = self;
    
    [self showFromBarButtonItem:item animated:animated];
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated withHandler:(completionBlock)completionBlock
{
    _completionBlock = completionBlock;
    self.delegate = self;
    
    [self showFromRect:rect inView:view animated:animated];
}

- (void)showInView:(UIView *)view withHandler:(completionBlock)completionBlock
{
    _completionBlock = completionBlock;
    self.delegate = self;
    
    [self showInView:view];
}

//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _completionBlock(buttonIndex);
}


@end
