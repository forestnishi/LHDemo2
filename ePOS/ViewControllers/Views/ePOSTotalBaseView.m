//
//  ePOSTotalBaseView.m
//  ePOS
//
//  Created by komatsu on 2014/06/17.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSTotalBaseView.h"
#import "ePOSSkinManager.h"

@implementation ePOSTotalBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    ePOSSkinManager *manager = [ePOSSkinManager sharedSkinManager];
    [manager drawTotalBase:context rect:rect];
    
    CGContextRestoreGState(context);
}

@end
