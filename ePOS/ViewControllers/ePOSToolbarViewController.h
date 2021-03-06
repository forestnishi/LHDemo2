//
//  ePOSToolbarViewController.h
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ePOSConnectStatus) {
    ePOSConnectStatusDisconnect,
    ePOSConnectStatusConnecting,
    ePOSConnectStatusConnected,
};

typedef NS_ENUM(NSInteger, ePOSToolbarIndicatorMode) {
    ePOSToolbarIndicatorModeOffline,
    ePOSToolbarIndicatorModeConnectiong,
    ePOSToolbarIndicatorModeOnline,
};


@protocol ePOSToolbarViewControllerDelegate;

@interface ePOSToolbarViewController : UIViewController

@property(nonatomic, weak) id<ePOSToolbarViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton *printerButton;
@property (nonatomic, weak) IBOutlet UIButton *displayButton;
@property (nonatomic, weak) IBOutlet UIButton *keyboardButton;
@property (nonatomic, weak) IBOutlet UIButton *scannerButton;

@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton *skinButton;
@property (nonatomic, weak) IBOutlet UIButton *languageButton;
@property (nonatomic, weak) IBOutlet UIButton *wifiButton;

@property (weak, nonatomic) IBOutlet UIButton *idScanButton;
@property (weak, nonatomic) IBOutlet UIButton *taxFreeButton;


@property (nonatomic, weak) IBOutlet UIImageView *logoView;

//@property (nonatomic, weak) IBOutlet UIButton *connectButton;

@property (nonatomic, weak) IBOutlet UIImageView *printerIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *displayIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *scannerIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *keyboardIndicator;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *printerActivity;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *displayActivity;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *scannerActivity;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *keyboardActivity;

@property (nonatomic) ePOSConnectStatus connectStatus;
@property (nonatomic) ePOSToolbarIndicatorMode printerReady;
@property (nonatomic) ePOSToolbarIndicatorMode displayReady;
@property (nonatomic) ePOSToolbarIndicatorMode scannerReady;
@property (nonatomic) ePOSToolbarIndicatorMode keyboardReady;

- (IBAction)pushSettings:(id)sender;
- (IBAction)pushSkin:(id)sender;
- (IBAction)pushLanguage:(id)sender;
- (IBAction)pushWifi:(id)sender;
- (IBAction)pushScanner:(id)sender;
- (IBAction)pushCamera:(id)sender;

@end

@protocol ePOSToolbarViewControllerDelegate <NSObject>
@optional

- (void)ePOSToolbarViewControllerDidSelectSkin:(ePOSToolbarViewController *)ePOSToolbarViewController;
- (void)ePOSToolbarViewControllerDidSelectSettings:(ePOSToolbarViewController *)ePOSToolbarViewController;
- (void)ePOSToolbarViewControllerDidSelectCamera:(ePOSToolbarViewController *)ePOSToolbarViewController;
- (void)ePOSToolbarViewControllerDidSelectScanner:(ePOSToolbarViewController *)ePOSToolbarViewController;
- (void)ePOSToolbarViewControllerDidSelectConnect:(ePOSToolbarViewController *)ePOSToolbarViewController;

@end
