//
//  ePOSCardView.h
//  ePOS
//
//  Created by komatsu on 2014/06/18.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ePOSSignView;

@interface ePOSCardView : UIView

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *okButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButoon;
@property (nonatomic, weak) IBOutlet UILabel *cardMessageLabel;

@property (nonatomic, weak) IBOutlet UIView *signBaseView;
@property (nonatomic, weak) IBOutlet ePOSSignView *signView;
@property (nonatomic, weak) IBOutlet UIButton *clearButton;
@property (nonatomic, weak) IBOutlet UILabel *totalLabel;

@property (nonatomic, readonly) NSArray *contentDictionary;

- (void)setupTarget:(id)target action:(SEL)action;
- (void)showSignView;
- (void)clearSign;

@end
