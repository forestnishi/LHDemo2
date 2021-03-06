//
//  ePOSCardView.m
//  ePOS
//
//  Created by komatsu on 2014/06/18.
//  Copyright (c) 2014年 iWare. All rights reserved.
//
#import <ImageIO/ImageIO.h>

#import "ePOSCardView.h"
#import "ePOSSignView.h"
#import "ePOSItemManager.h"
#import "ePOSSkinManager.h"

@implementation ePOSCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupTarget:(id)target action:(SEL)action
{
    [_okButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [_closeButoon addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [_clearButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"swipe" withExtension:@"gif"];
//    [_webView loadRequest:[NSURLRequest requestWithURL:url]];

    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    _cardMessageLabel.text = EPOSLocalizedString(@"Entering a Credit Card", skinManager.language, nil);

    [_clearButton setTitle:EPOSLocalizedString(@"Clear Sign", skinManager.language, nil) forState:UIControlStateNormal];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"swipe" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSArray *array = [self arrayWithGifData:data];
    _imageView.image = [array lastObject];
    _imageView.animationImages = array;
    _imageView.animationDuration = 1.;
    _imageView.animationRepeatCount = 1;
    [_imageView startAnimating];
}

- (void)showSignView
{
    _signBaseView.hidden = NO;
    _totalLabel.hidden = NO;
    
    ePOSItemManager *itemManager = [ePOSItemManager sharedItemManager];
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    NSString *totalString = EPOSLocalizedString(@"Card Total : ", skinManager.language, nil);
    _totalLabel.text = [NSString stringWithFormat:@"%@%@", totalString, itemManager.total];
    _cardMessageLabel.text = EPOSLocalizedString(@"Signature", skinManager.language, nil);
}

- (void)clearSign
{
    [_signView clearSign];
}

- (NSArray *)contentDictionary
{
    return _signView.contentDicts;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (UIImage *)animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray* images = [NSMutableArray array];
    
    NSTimeInterval duration = 0.0f;
    
    for (size_t i = 0; i < count; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        
        NSDictionary* frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));
        duration += [[[frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary] objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
        
        [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
        
        CGImageRelease(image);
    }
    
    CFRelease(source);
    
    if (!duration) {
        duration = (1.0f/10.0f)*count;
    }
    
    return [UIImage animatedImageWithImages:images duration:duration];
}

- (NSArray *)arrayWithGifData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray* images = [NSMutableArray array];
    
    NSTimeInterval duration = 0.0f;
    
    for (size_t i = 0; i < count; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        
        NSDictionary* frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));
        duration += [[[frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary] objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
        
        [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
        
        CGImageRelease(image);
    }
    
    CFRelease(source);
    
    return images;
}


@end
