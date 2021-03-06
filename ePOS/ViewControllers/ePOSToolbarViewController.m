//
//  ePOSToolbarViewController.m
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSToolbarViewController.h"
#import "ePOSSkinManager.h"
#import "ePOSUserDefault.h"

#import "IWUIAlertView.h"

#import "ePOSAgent.h"



@interface ePOSToolbarViewController ()
{
    ePOSSkinManager *_skinManager;
    ePOSConnectStatus _connect;
    NSTimer *_timer;
}
@end

@implementation ePOSToolbarViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _skinManager = [ePOSSkinManager sharedSkinManager];
    [self redrawView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawView) name:ePOSChangeSkinNotification object:nil];
    _timer = nil;

//    self.printerReady = ePOSToolbarIndicatorModeOffline;
//    self.displayReady = ePOSToolbarIndicatorModeOffline;
//    self.scannerReady = ePOSToolbarIndicatorModeOffline;
//    self.keyboardReady = ePOSToolbarIndicatorModeOffline;
    
//    [_printerActivity stopAnimating];
//    [_scannerActivity stopAnimating];
//    [_displayActivity stopAnimating];
//    [_keyboardActivity stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setConnectStatus:(ePOSConnectStatus)connectStatus
{
    _connect = connectStatus;
    if(_connect == ePOSConnectStatusDisconnect) {
        _wifiButton.enabled = YES;
        [_wifiButton setImage:_skinManager.toolBarButtonWifiOFF forState:UIControlStateNormal];
        [_timer invalidate];
        _timer = nil;
        _wifiButton.alpha = 1.;
    } else if(_connect == ePOSConnectStatusConnecting) {
        _wifiButton.enabled = NO;
        [_wifiButton setImage:_skinManager.toolBarButtonWifiON forState:UIControlStateNormal];
        if(_timer == nil) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(idleProcess) userInfo:nil repeats:YES];
        }
        _wifiButton.alpha = 1.;
    } else {
        _wifiButton.enabled = YES;
        [_wifiButton setImage:_skinManager.toolBarButtonWifiON forState:UIControlStateNormal];
        [_timer invalidate];
        _timer = nil;
        _wifiButton.alpha = 1.;
    }
}

- (ePOSConnectStatus)connectStatus
{
    return _connect;
}

- (void)idleProcess
{
    [UIView animateWithDuration:.3 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if(_wifiButton.alpha == 1.) {
            _wifiButton.alpha = 0.;
        } else {
            _wifiButton.alpha = 1.;
        }
    } completion:^(BOOL finished) {
    }];
}

- (BOOL)connect
{
    return _connect;
}

- (void)setPrinterReady:(ePOSToolbarIndicatorMode)mode
{
    if(mode == ePOSToolbarIndicatorModeOnline) {
        _printerIndicator.hidden = NO;
        _printerIndicator.image = [UIImage imageNamed:@"ok"];
        [_printerActivity stopAnimating];
    } else if(mode == ePOSToolbarIndicatorModeOffline){
        _printerIndicator.hidden = NO;
        _printerIndicator.image = [UIImage imageNamed:@"ng"];
        [_printerActivity stopAnimating];
    } else if(mode == ePOSToolbarIndicatorModeConnectiong) {
        _printerIndicator.hidden = YES;
        [_printerActivity startAnimating];
    }
}

- (void)setScannerReady:(ePOSToolbarIndicatorMode)mode
{
    if(mode == ePOSToolbarIndicatorModeOnline) {
        _scannerIndicator.hidden = NO;
        _scannerIndicator.image = [UIImage imageNamed:@"ok"];
        [_scannerActivity stopAnimating];
    } else if(mode == ePOSToolbarIndicatorModeOffline){
        _scannerIndicator.hidden = NO;
        _scannerIndicator.image = [UIImage imageNamed:@"ng"];
        [_scannerActivity stopAnimating];
    } else if(mode == ePOSToolbarIndicatorModeConnectiong) {
        _scannerIndicator.hidden = YES;
        [_scannerActivity startAnimating];
    }
}

- (void)setDisplayReady:(ePOSToolbarIndicatorMode)mode
{
    if(mode == ePOSToolbarIndicatorModeOnline) {
        _displayIndicator.hidden = NO;
        _displayIndicator.image = [UIImage imageNamed:@"ok"];
        [_displayActivity stopAnimating];
    } else if(mode == ePOSToolbarIndicatorModeOffline){
        _displayIndicator.hidden = NO;
        _displayIndicator.image = [UIImage imageNamed:@"ng"];
        [_displayActivity stopAnimating];
    } else if(mode == ePOSToolbarIndicatorModeConnectiong) {
        _displayIndicator.hidden = YES;
        [_displayActivity startAnimating];
    }
}

- (void)setKeyboardReady:(ePOSToolbarIndicatorMode)mode
{
#if 1
    _keyboardIndicator.hidden = YES;
    [_keyboardActivity stopAnimating];

#else
    if(mode == ePOSToolbarIndicatorModeOnline) {
        _keyboardIndicator.hidden = NO;
        _keyboardIndicator.image = [UIImage imageNamed:@"ok"];
        [_keyboardActivity stopAnimating];
    } else if(mode == ePOSToolbarIndicatorModeOffline){
        _keyboardIndicator.hidden = NO;
        _keyboardIndicator.image = [UIImage imageNamed:@"ng"];
        [_keyboardActivity stopAnimating];
    } else if(mode == ePOSToolbarIndicatorModeConnectiong) {
        _keyboardIndicator.hidden = YES;
        [_keyboardActivity startAnimating];
    }
#endif
}

- (IBAction)pushSettings:(id)sender
{
    if ( [self.delegate respondsToSelector:@selector(ePOSToolbarViewControllerDidSelectSettings:)] ) {
        [self.delegate ePOSToolbarViewControllerDidSelectSettings:self];
    }
}

- (IBAction)pushSkin:(id)sender
{
#if 1
    if ( [self.delegate respondsToSelector:@selector(ePOSToolbarViewControllerDidSelectSkin:)] ) {
        [self.delegate ePOSToolbarViewControllerDidSelectSkin:self];
    }
#else
    ePOSSkinType type = _skinManager.skinType;
    type += 1;
    if(type > ePOSSkinTypeEND) {
        type = ePOSSkinTypeSTART;
    }
    _skinManager.skinType = type;
    [[NSNotificationCenter defaultCenter] postNotificationName:ePOSChangeSkinNotification object:self];
#endif
}

- (IBAction)pushLanguage:(id)sender
{
    ePOSLanguage language = _skinManager.language;
    if(language == ePOSLanguageEnglish) {
        _skinManager.language = ePOSLanguageJapanese;
    }
    else {
        _skinManager.language = ePOSLanguageEnglish;
    }

    [[NSUserDefaults standardUserDefaults] setInteger:(int)_skinManager.language forKey:ePOSDefaultLanguageKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ePOSChangeSkinNotification object:self];
}

- (IBAction)pushWifi:(id)sender
{
    if ( [self.delegate respondsToSelector:@selector(ePOSToolbarViewControllerDidSelectConnect:)] ) {
        [self.delegate ePOSToolbarViewControllerDidSelectConnect:self];
    }
}

- (IBAction)pushScanner:(id)sender
{
    if ( [self.delegate respondsToSelector:@selector(ePOSToolbarViewControllerDidSelectScanner:)] ) {
        [self.delegate ePOSToolbarViewControllerDidSelectScanner:self];
    }

}



- (IBAction)pushCamera:(id)sender
{
    if ( [self.delegate respondsToSelector:@selector(ePOSToolbarViewControllerDidSelectCamera:)] ) {
        [self.delegate ePOSToolbarViewControllerDidSelectCamera:self];
    }
}

- (IBAction)pushConnect:(id)sender
{

}

- (IBAction)pushIdScan:(id)sender {
    //if(_itemManager.count != 0) {
    
    IWUIAlertView *alert =
    [[IWUIAlertView alloc] initWithTitle:@"会員IDを読み込んでください"
                                 message:nil
                                delegate:nil
                       cancelButtonTitle:EPOSLocalizedString(@"Cancel", _skinManager.language, nil)
                       otherButtonTitles:EPOSLocalizedString(@"OK", _skinManager.language, nil), nil];
    
    //[alert Completion]
    [alert showWithCompletionHandler:^(NSInteger button){
        if(button == 1) {
            //  [self removeAllItems];
        }
    }];
    //}
}

- (IBAction)pushTaxFree:(id)sender {
    //if(_itemManager.count != 0) {
    
    IWUIAlertView *alert =
    [[IWUIAlertView alloc] initWithTitle:@"パスポートを読み込んでください"
                                 message:nil
                                delegate:nil
                       cancelButtonTitle:EPOSLocalizedString(@"Cancel", _skinManager.language, nil)
                       otherButtonTitles:EPOSLocalizedString(@"OK", _skinManager.language, nil), nil];
    
    //[alert Completion]
    [alert showWithCompletionHandler:^(NSInteger button){
        if(button == 1) {
            //  [self removeAllItems];
        }
    }];
    //}
}
//- (void)startMemberIDScanner
//{
//    ePOSAgent *agent = [ePOSAgent sharedAgent];
//    [agent startScanCompletion:^(NSString *scanString) {
//
//        //商品コード
//        if([scanString hasPrefix:@"100"]) {
//            [self addItem:scanString];
//
//            //会員ID
//        }else if([scanString isEqualToString:@"2874900190406"] ){
//            //
//        }
//
//        //免税
//    }];
//}


- (void)redrawView
{
    self.view.backgroundColor = _skinManager.backgroundColor;
    UIImage *image = _skinManager.toolBarImage;
    if(image) {
        self.view.layer.contentsGravity = @"resizeAspect";
        self.view.layer.contents = (__bridge id)(image.CGImage);
    } else {
        self.view.layer.contents = nil;
    }
    [self.view setNeedsDisplay];
    
    [_printerButton setImage:_skinManager.toolBarPrinterImage forState:UIControlStateNormal];
    [_displayButton setImage:_skinManager.toolBarDisplayImage forState:UIControlStateNormal];
    [_keyboardButton setImage:_skinManager.toolBarKeyboardImage forState:UIControlStateNormal];
    [_scannerButton setImage:_skinManager.toolBarScannerImage forState:UIControlStateNormal];
    
    [_settingsButton setImage:_skinManager.toolBarButtonSettings forState:UIControlStateNormal];
    [_skinButton setImage:_skinManager.toolBarButtonSkin forState:UIControlStateNormal];
    [_languageButton setImage:_skinManager.toolBarButtonLanguage forState:UIControlStateNormal];
//    [_wifiButton setImage:_skinManager.toolBarButtonWifiOFF forState:UIControlStateNormal];
    [self setConnectStatus:_connect];
    _logoView.image = _skinManager.toolBarLogoImage;
    
    _printerActivity.activityIndicatorViewStyle = _skinManager.indicatorStyle;
    _scannerActivity.activityIndicatorViewStyle = _skinManager.indicatorStyle;
    _displayActivity.activityIndicatorViewStyle = _skinManager.indicatorStyle;
    _keyboardActivity.activityIndicatorViewStyle = _skinManager.indicatorStyle;
}


@end
