//
//  ePOSItemBackgroundView.m
//  ePOS
//
//  Created by komatsu on 2014/06/18.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSItemBackgroundView.h"
#import "ePOSSkinManager.h"

@implementation ePOSItemBackgroundView

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

    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    [skinManager drawItemBase:context rect:rect];
    
    CGContextRestoreGState(context);
}

@end
