//
//  ePOSSignView.m
//  ePOS
//
//  Created by komatsu on 2014/06/18.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSignView.h"

#define LINE_WIDTH (4.)
@implementation ePOSSignView
{
    UIPanGestureRecognizer *_panGestureRecognizer;
    UIBezierPath *_currentPath;
    CGPoint _prevLocation;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(recognizePanGesture:)];
        _panGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:_panGestureRecognizer];
        
        _contentDicts = [[NSMutableArray alloc] init];
        
        self.layer.drawsAsynchronously = YES;

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    [[UIColor blackColor] set];
    // Drawing code
    for ( NSDictionary *contentDict in _contentDicts )
    {
        UIBezierPath *bezierPath = contentDict[@"DrawBezierPathKey"];
        bezierPath.lineWidth = LINE_WIDTH;
        bezierPath.lineJoinStyle = kCGLineJoinRound;
        [bezierPath stroke];
    }
    [_currentPath stroke];
    
    CGContextRestoreGState(context);
}


- (void)recognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    if ( recognizer.state == UIGestureRecognizerStateBegan )
    {
        _currentPath = [[UIBezierPath alloc] init];
        _currentPath.lineCapStyle = kCGLineCapRound;
        _currentPath.lineJoinStyle = kCGLineJoinRound;
        _currentPath.lineWidth = LINE_WIDTH;
        [_currentPath moveToPoint:location];
        _prevLocation = location;
    }
    else if ( recognizer.state == UIGestureRecognizerStateChanged )
    {
        [_currentPath addLineToPoint:location];
        CGRect updateRect = CGRectMake(MIN(_prevLocation.x, location.x),
                                       MIN(_prevLocation.y, location.y),
                                       ABS(location.x - _prevLocation.x),
                                       ABS(location.y - _prevLocation.y));

        updateRect = CGRectInset(updateRect, -LINE_WIDTH / 2, -LINE_WIDTH / 2);
        [self setNeedsDisplayInRect:updateRect];
        _prevLocation = location;
    }
    else if ( recognizer.state == UIGestureRecognizerStateEnded )
    {
        {
            [_contentDicts addObject:@{@"DrawBezierPathKey" : _currentPath}];
        }
        _currentPath = nil;
        _prevLocation = CGPointZero;
    }
}

- (void)clearSign
{
    [_contentDicts removeAllObjects];
    [self setNeedsDisplay];
}
@end
