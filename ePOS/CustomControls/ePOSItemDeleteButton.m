//
//  ePOSItemDeleteButton.m
//  ePOS
//
//  Created by komatsu on 2014/06/17.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSItemDeleteButton.h"
#import "ePOSSkinManager.h"

@implementation ePOSItemDeleteButton
{
    ePOSSkinManager *_skinManager;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _skinManager = [ePOSSkinManager sharedSkinManager];
        [self setTitle:nil forState:UIControlStateNormal];
        self.backgroundColor = [UIColor clearColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:ePOSChangeSkinNotification object:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    NSString *titleStr = EPOSLocalizedString(self.buttonTitle, _skinManager.language, nil);

    [_skinManager drawItemDeleteButton:context rect:rect isHighlighted:self.isHighlighted name:titleStr];
    
    CGContextRestoreGState(context);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
    
}

@end
