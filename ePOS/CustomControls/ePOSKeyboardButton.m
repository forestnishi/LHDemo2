//
//  ePOSKeyboardButton.m
//  ePOS
//
//  Created by komatsu on 2014/06/13.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSKeyboardButton.h"
#import "ePOSSkinManager.h"
#import "ePOSKeyboardHighlightedView.h"

@implementation ePOSKeyboardButton
{
    ePOSSkinManager *_skinManager;
    ePOSKeyboardHighlightedView *_highlightView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _skinManager = [ePOSSkinManager sharedSkinManager];
        [self setTitle:nil forState:UIControlStateNormal];
        self.backgroundColor = [UIColor clearColor];
        
        if(self.tag < 20) {
            NSString *title = EPOSLocalizedString([self stringFromTag:self.tag], _skinManager.language, nil);
            _highlightView = [[ePOSKeyboardHighlightedView alloc] initWithFrame:CGRectOffset(self.bounds, 0., -50.) title:title];
            [self addSubview:_highlightView];
            _highlightView.alpha = 0.;
        } else {
            _highlightView = nil;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:ePOSChangeSkinNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    
    NSString *titleStr = EPOSLocalizedString([self stringFromTag:self.tag], _skinManager.language, nil);

    BOOL hilight = self.isHighlighted | self.isSelected;
    [_skinManager drawKeyboard:context rect:rect isHighlighted:hilight name:titleStr tag:self.tag];
    
    CGContextRestoreGState(context);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
    if(self.tag < 20) {
        if(highlighted) {
            [self.superview bringSubviewToFront:self];
            _highlightView.alpha = 1.;
        } else {
            _highlightView.alpha = 0.;
        }
    }
}

#pragma mark - private
- (NSString *)stringFromTag:(NSInteger)tag
{
    return [_skinManager keyboardTitleFromTag:tag];
}
@end
