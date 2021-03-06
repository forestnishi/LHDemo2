//
//  ePOSTotalLabel.m
//  ePOS
//
//  Created by komatsu on 2014/07/29.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSTotalLabel.h"

@implementation ePOSTotalLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 4.;
        self.layer.borderWidth = 1.;
        self.layer.borderColor = [UIColor colorWithRed:1. green:1. blue:1. alpha:1.].CGColor;
        self.layer.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.8].CGColor;
    }
    return self;
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
