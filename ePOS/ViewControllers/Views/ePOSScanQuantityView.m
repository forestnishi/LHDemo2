//
//  ePOSScanQuantityView.m
//  ePOS
//
//  Created by komatsu on 2014/06/25.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSScanQuantityView.h"
#import "ePOSSkinManager.h"

@implementation ePOSScanQuantityView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 15.;
        self.layer.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.5].CGColor;
    }
    return self;
}

- (void)setQuantity:(NSInteger)quantity
{
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    _quantityLabel.text = [@(quantity) stringValue];
    _quantityTitleLabel.text = EPOSLocalizedString(@"Scan", skinManager.language, nil);
    [self setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
