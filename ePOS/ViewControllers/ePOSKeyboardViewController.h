//
//  ePOSKeyboardViewController.h
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ePOSKeyboardKeyKind) {
    ePOSKeyboardKeyKindZeroZero = 10,
    ePOSKeyboardKeyKindPeriod   = 11,
    ePOSKeyboardKeyKindEnter    = 12,
    ePOSKeyboardKeyKindMinus    = 13,
    ePOSKeyboardKeyKindPlus     = 14,
    ePOSKeyboardKeyKindClear    = 15,
    ePOSKeyboardKeyKindCash     = 20,
    ePOSKeyboardKeyKindCard     = 21,
    ePOSKeyboardKeyKindScan     = 22,
};

typedef NS_ENUM(NSInteger, ePOSKeyboardMode) {
    ePOSKeyboardModeNone,
    ePOSKeyboardModeNormal,
    ePOSKeyboardModeDeposit,
    ePOSKeyboardModeIemCode,
};


@protocol ePOSKeyboardViewControllerDelegate;

@interface ePOSKeyboardViewController : UIViewController

@property(nonatomic, weak) id<ePOSKeyboardViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton *cashButton;
@property (nonatomic, weak) IBOutlet UIButton *cardButton;
@property (nonatomic, weak) IBOutlet UIButton *scanButton;

@property (nonatomic) ePOSKeyboardMode keyBoardMode;

- (IBAction)pushCard:(UIButton *)sender;
- (IBAction)pushCash:(UIButton *)sender;
- (IBAction)pushNumber:(UIButton *)sender;
- (IBAction)pushControl:(UIButton *)sender;

@end

@protocol ePOSKeyboardViewControllerDelegate <NSObject>
@optional

- (void)ePOSKeyboardViewControllerDidSelectScanner:(ePOSKeyboardViewController *)ePOSKeyboardViewController;
- (void)ePOSKeyboardViewControllerDidSelectCard:(ePOSKeyboardViewController *)ePOSKeyboardViewController;
- (void)ePOSKeyboardViewControllerDidSelectCash:(ePOSKeyboardViewController *)ePOSKeyboardViewController;
- (void)ePOSKeyboardViewController:(ePOSKeyboardViewController *)ePOSKeyboardViewController didSelectNumber:(NSInteger)number;
- (void)ePOSKeyboardViewController:(ePOSKeyboardViewController *)ePOSKeyboardViewController didSelectControl:(NSInteger)number;

@end