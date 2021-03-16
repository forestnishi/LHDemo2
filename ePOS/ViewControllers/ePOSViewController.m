//
//  ePOSViewController.m
//  ePOS
//
//  Created by komatsu on 2014/06/13.
//  Copyright (c) 2014年 iWare. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "ePOSViewController.h"

#import "ePosSkinManager.h"
#import "ePOSKeyboardViewController.h"
#import "ePOSCardView.h"
#import "ePOSItemViewController.h"
#import "ePOSAgent.h"
#import "ePOSUserDefault.h"
#import "ePOS2.h"
#import "ePOSDataManager.h"
#import "IWUIAlertView.h"
#import "ePOSScanQuantityView.h"
#import "ePOSItemManager.h"
#import "ePOSTotalViewController.h"
#import "ePOSToolbarViewController.h"
#import "ePOSPrintManager.h"
#import "ePOSErrorMessage.h"
#import "ePOSSettingsTableViewController.h"
#import "ePOSOverlayView.h"

#if !TARGET_IPHONE_SIMULATOR
#define HAS_AVFF 1
#endif

#define USE_SYSTEMSOUND 1


NSString * const ePOSDisconnectNotification              = @"ePOSDisconnectNotification";


@interface ePOSViewController ()
{
    ePOSSkinManager *_skinManager;
    ePOSDataManager *_dataManager;
    ePOSCardView *_cardView;

    NSInteger _cardSignPhase;
    NSArray *_signArray;
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_preview;
    BOOL _isSessionStart;
#ifdef USE_SYSTEMSOUND
    SystemSoundID _beepSound;
#else
    AVAudioPlayer *_player;
#endif
    BOOL _connected;
    BOOL _quantityClearFlag;

    ePOSScanQuantityView *_scanQuantityView;
    ePOSItemViewController *_itemViewController;
    ePOSItemManager *_itemManager;
    ePOSTotalViewController *_totalViewController;
    ePOSToolbarViewController *_toolbarViewController;
    ePOSKeyboardViewController *_keyboardViewController;
    //NSTimer *_idleTimer;
    NSUInteger _idleCount;
    BOOL _isIdle;
    //BOOL _showMarqee;
    ePOSKeyboardMode _keyboardMode;
    ePOSOverlayView *_overLay;
    BOOL _processing;
    
    NSString* _taxForTaxFree;
    NSString* _netForTaxFree;
}
@end

@implementation ePOSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _skinManager = [ePOSSkinManager sharedSkinManager];
    _dataManager = [ePOSDataManager sharedDataManager];
    _itemManager = [ePOSItemManager sharedItemManager];
    
    [self redrawView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawView) name:ePOSChangeSkinNotification object:nil];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	[_skinSelectView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *itemTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleItemTapGesture:)];
#if !TARGET_IPHONE_SIMULATOR
    itemTapGesture.numberOfTouchesRequired = 4;
#endif
    itemTapGesture.numberOfTapsRequired = 2;
	[_itemView addGestureRecognizer:itemTapGesture];

    
    [self initCaptureDevice];
    
    _connected = NO;
    _itemManager.currentQuantity = 1;
    _quantityClearFlag = YES;
    
    UINib *nib = [UINib nibWithNibName:@"ScanQuantityView" bundle:nil];
    _scanQuantityView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.view addSubview:_scanQuantityView];
    _scanQuantityView.alpha = 0.;
    
    _toolbarViewController.printerReady = ePOSToolbarIndicatorModeOffline;
    _toolbarViewController.displayReady = ePOSToolbarIndicatorModeOffline;
    _toolbarViewController.scannerReady = ePOSToolbarIndicatorModeOffline;
    _toolbarViewController.keyboardReady = ePOSToolbarIndicatorModeOffline;

    _isIdle = NO;

    _keyboardMode = ePOSKeyboardModeNone;
    _keyboardViewController.keyBoardMode = _keyboardMode;
    _itemViewController.keyBoardMode = _keyboardMode;
    
    _processing = NO;
    
    //[self connect];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)redrawView
{
    self.view.backgroundColor = _skinManager.backgroundColor;
    UIImage *image = _skinManager.backgroundImage;
    if(image) {
        self.view.layer.contents = (__bridge id)(image.CGImage);
    } else {
        self.view.layer.contents = nil;
    }
    [self.view setNeedsDisplay];
    
    if(_keyboardMode == ePOSKeyboardModeDeposit) {
        [_totalViewController updateAll];
    }
}

- (IBAction)returnActionForSegue:(UIStoryboardSegue *)segue
{
    
}

- (IBAction)pushBlackSkin:(id)sender
{
    _skinManager.skinType = ePOSSkinTypeBlack;
    [self hideSkinSelecctView:0.1];
    [[NSUserDefaults standardUserDefaults] setObject:@(_skinManager.skinType) forKey:ePOSDefaultSkinTypeKey];
}

- (IBAction)pushPinkSkin:(id)sender
{
    _skinManager.skinType = ePOSSkinTypePink;
    [self hideSkinSelecctView:0.1];
    [[NSUserDefaults standardUserDefaults] setObject:@(_skinManager.skinType) forKey:ePOSDefaultSkinTypeKey];
}

- (IBAction)pushYellowSkin:(id)sender
{
    _skinManager.skinType = ePOSSkinTypeOrange;
    [self hideSkinSelecctView:0.1];
    [[NSUserDefaults standardUserDefaults] setObject:@(_skinManager.skinType) forKey:ePOSDefaultSkinTypeKey];
}

- (IBAction)pushPurpleSkin:(id)sender
{
    _skinManager.skinType = ePOSSkinTypePurple;
    [self hideSkinSelecctView:0.1];
    [[NSUserDefaults standardUserDefaults] setObject:@(_skinManager.skinType) forKey:ePOSDefaultSkinTypeKey];
}

- (IBAction)pushCard:(id)sender
{
    UIButton *button = sender;
    
    if(button.tag == 1) {           // ok
        if(_cardSignPhase == 0) {
            _cardSignPhase = 1;
            [_cardView showSignView];
            _signArray = nil;
        } else {
            _signArray = _cardView.contentDictionary;
            [self printReceipt];
            [self hideCardView];
        }
    } else if(button.tag == 2) {    // close
        [self hideCardView];
        _signArray = nil;   // ??
    } else if(button.tag == 3) {    // clear
        [_cardView clearSign];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ePOSToolbar"]) {
        _toolbarViewController = segue.destinationViewController;
        _toolbarViewController.delegate = self;
    } else if([segue.identifier isEqualToString:@"ePOSKeyboard"]) {
        _keyboardViewController = segue.destinationViewController;
        _keyboardViewController.delegate = self;
    } else if([segue.identifier isEqualToString:@"ePOSItem"]) {
        _itemViewController = segue.destinationViewController;
        _itemViewController.delegate = self;
    } else if([segue.identifier isEqualToString:@"ePOSTotal"])
    {
        _totalViewController = segue.destinationViewController;
    } else if([segue.identifier isEqualToString:@"ShowSettings"]) {
        UINavigationController *navi = segue.destinationViewController;
        ePOSSettingsTableViewController *controller = (ePOSSettingsTableViewController *)navi.topViewController;
        controller.viewController = self;
    }
}

- (void)startScanner
{
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    [agent startScanCompletion:^(NSString *scanString) {
        
        //商品コード
        if([scanString hasPrefix:@"100"] || [scanString hasPrefix:@"21"]) {
            [self addItem:scanString];
            
        //会員ID
        }else if([scanString isEqualToString:@"2874900190406"] ){
            [_itemViewController setMemberID:@"2874900190406"];
            
            
        //免税
        }else  if([scanString isEqualToString:@"P<JPNSHINJUKU<<TARO<<<<<<<<<<<<<<<<<<<<<<<<<TE51857854JPN6504050M0703275<<<<<<<<<<<<<<<4"] ){
            
            
            IWUIAlertView *alert =
            [[IWUIAlertView alloc] initWithTitle:@"免税手続き"
                                         message:@"国籍:JPN\nパスポート番号:TE51857854\n名:TARO\n姓:SINJUKU\n性別:M\n生年月日:5/4/1965\n"
                                        delegate:nil
                               cancelButtonTitle:@"キャンセル"
                               otherButtonTitles:@"印刷",nil];
            [alert showWithCompletionHandler:^(NSInteger button){
                if(button == 1) {
                    [self printTaxFree];
                }
            }];
            
            
        }
    }];
}


#pragma mark - delegate
// ePOSToolbarViewControllerDelegate

// スキンボタンをタップ
- (void)ePOSToolbarViewControllerDidSelectSkin:(ePOSToolbarViewController *)ePOSToolbarViewController
{
    if(_processing) return;
    [self showSkinSelectView];
}

// 設定をタップ
- (void)ePOSToolbarViewControllerDidSelectSettings:(ePOSToolbarViewController *)ePOSToolbarViewController
{
    [self performSegueWithIdentifier:@"ShowSettings" sender:nil];
}

// スキャンボタンをタップ（商品追加）
- (void)ePOSToolbarViewControllerDidSelectScanner:(ePOSToolbarViewController *)ePOSToolbarViewController
{
    NSString *code = [_dataManager randomCode];
    [self addItem:code];
}

// ePOSKeyboardViewControllerDelegate

// テンキーをタップ
- (void)ePOSKeyboardViewController:(ePOSKeyboardViewController *)ePOSKeyboardViewController didSelectNumber:(NSInteger)number;
{
    if(_keyboardMode == ePOSKeyboardModeNormal || _keyboardMode == ePOSKeyboardModeNone) {
        if(number == ePOSKeyboardKeyKindZeroZero || number == ePOSKeyboardKeyKindPeriod) return;
        
        if(_quantityClearFlag) {
            _itemManager.currentQuantity = 0;
            _quantityClearFlag = NO;
            if(number == 0) number = 1;
        }
        _itemManager.currentQuantity = _itemManager.currentQuantity * 10 + number;
        if(_itemManager.currentQuantity > 99) {
            _itemManager.currentQuantity = 99;
        }
        [self showScanQuantityView];
    } else if(_keyboardMode == ePOSKeyboardModeDeposit) {
        [_totalViewController pushKeyboard:number];
    } else if(_keyboardMode == ePOSKeyboardModeIemCode) {
        [_itemViewController pushKeyboard:number];
    }
}

// テンキーのコントロールキーをタップ
- (void)ePOSKeyboardViewController:(ePOSKeyboardViewController *)ePOSKeyboardViewController didSelectControl:(NSInteger)number
{
    switch (number) {
        case ePOSKeyboardKeyKindEnter:    // Enter
            if(_keyboardMode == ePOSKeyboardModeNormal) {
                _isIdle = YES;
                _idleCount = 5;
            } else if(_keyboardMode == ePOSKeyboardModeDeposit) {
                if([_itemManager checkDeposit]) {
                    [_totalViewController updateDeposit];
                } else {
                    [_totalViewController updateChange];
                    if([_itemManager isSufficient]) {
                        _signArray = nil;
                        [self printReceipt];
                    } else {
                        IWUIAlertView *alert =
                        [[IWUIAlertView alloc] initWithTitle:EPOSLocalizedString(@"Cash is less than subtotal.", _skinManager.language, nil)
                                                     message:nil
                                                    delegate:nil
                                           cancelButtonTitle:EPOSLocalizedString(@"OK", _skinManager.language, nil)
                                           otherButtonTitles:nil, nil];
                        [alert showWithCompletionHandler:^(NSInteger button){
                        }];
                    }
                }
            }
            break;

        case ePOSKeyboardKeyKindMinus:    // -
        {
            if(_isSessionStart) {
                return;
            }
            [_itemViewController updateQuantity:NO];
            [_totalViewController updateTotal];
            ePOSAgent *agent = [ePOSAgent sharedAgent];
            if( agent.isEposDisplay ) [agent clearDisplay];
            if( agent.isEposDisplay ) [agent displayAllingedText:EPOSLocalizedString(@"Phonetic_Subtotal", _skinManager.language, nil) valueStr:_itemManager.phoneticTotal yPosition:2];
            break;
        }
        case ePOSKeyboardKeyKindPlus:    // +
        {
            if(_isSessionStart) {
                return;
            }
            [_itemViewController updateQuantity:YES];
            [_totalViewController updateTotal];
            ePOSAgent *agent = [ePOSAgent sharedAgent];
            if( agent.isEposDisplay ) [agent clearDisplay];
            if( agent.isEposDisplay ) [agent displayAllingedText:EPOSLocalizedString(@"Phonetic_Subtotal", _skinManager.language, nil) valueStr:_itemManager.phoneticTotal yPosition:2];

            break;
        }
        case ePOSKeyboardKeyKindClear:    // Clear
            if(_isSessionStart) {
                _isSessionStart = NO;
                _processing = NO;
                [_session stopRunning];
                [_preview removeFromSuperlayer];
                [_overLay removeFromSuperview];
                _keyboardViewController.scanButton.selected = NO;
            } else {
                if(_keyboardMode == ePOSKeyboardModeNormal || _keyboardMode == ePOSKeyboardModeNone) {
                    _itemManager.currentQuantity = 1;
                    _quantityClearFlag = YES;
                    [self showScanQuantityView];
                } else if(_keyboardMode == ePOSKeyboardModeDeposit) {
                    if(_itemManager.depositValue != 0) {
                        [_totalViewController clearDeposit];
                        [_totalViewController updateChange];
                    } else {
                        [_totalViewController clearDeposit];
                        [_totalViewController updateChange];
                        _keyboardMode = ePOSKeyboardModeNormal;
                        _itemViewController.keyBoardMode = _keyboardMode;
                        _keyboardViewController.keyBoardMode = _keyboardMode;
                        _totalViewController.depositMode = NO;
                    }
                } else if(_keyboardMode == ePOSKeyboardModeIemCode) {
                    [_itemViewController clearItemCode];
                }
            }
            break;

        default:
            break;
    }
}

// カードキーをタップ
- (void)ePOSKeyboardViewControllerDidSelectCard:(ePOSKeyboardViewController *)ePOSKeyboardViewController
{
    if(_processing) return;
    [self showCardView];
}

// スキャン開始／終了
- (void)ePOSKeyboardViewControllerDidSelectScanner:(ePOSKeyboardViewController *)ePOSKeyboardViewController;
{
#if HAS_AVFF
    if(_isSessionStart) {
        _processing = NO;
        _isSessionStart = NO;
        [_session stopRunning];
        [_preview removeFromSuperlayer];
        [_overLay removeFromSuperview];
    } else {
        if(_processing) {
            _keyboardViewController.scanButton.selected = NO;
            return;
        }
        _processing = YES;
        _isSessionStart = YES;
//        CGFloat angle = 90.;
//        if([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft) {
//            angle = -90.;
//        }
//        _preview.affineTransform = CGAffineTransformMakeRotation(angle * M_PI / 180.);
        [_session startRunning];
        [self.view.layer addSublayer:_preview];
        [self.view addSubview:_overLay];
    }
#endif
}

- (void)ePOSKeyboardViewControllerDidSelectCash:(ePOSKeyboardViewController *)ePOSKeyboardViewController;
{
    if(_processing) return;
    _keyboardMode = ePOSKeyboardModeDeposit;
    _totalViewController.depositMode = YES;
    _itemViewController.keyBoardMode = _keyboardMode;
    _keyboardViewController.keyBoardMode = _keyboardMode;
}

// 接続ボタンをタップ
- (void)ePOSToolbarViewControllerDidSelectConnect:(ePOSToolbarViewController *)ePOSToolbarViewController
{
    if(_connected) {
        [self disconnect];
    } else {
        [self connect];
    }
}

// ePOSItemViewController
// 商品コード入力
- (void)ePOSItemViewController:(ePOSItemViewController *)ePOSItemViewController didSelectItemCode:(BOOL)mode;
{
    if(mode == YES) {
        _keyboardMode = ePOSKeyboardModeIemCode;
    } else {
        if(_itemManager.count == 0) {
            _keyboardMode = ePOSKeyboardModeNone;
        } else {
            _keyboardMode = ePOSKeyboardModeNormal;
        }
    }
    _keyboardViewController.keyBoardMode = _keyboardMode;
}

// 商品追加
- (void)ePOSItemViewController:(ePOSItemViewController *)ePOSItemViewController addItem:(NSString *)code;
{
    [self addItem:code];
}

// 商品ビュー更新
- (void)ePOSItemViewControllerDidUpdateItems:(ePOSItemViewController *)ePOSItemViewController;
{
    [_totalViewController updateAll];
    if(_itemManager.count == 0) {
        _keyboardMode = ePOSKeyboardModeNone;
        _keyboardViewController.keyBoardMode = _keyboardMode;
    }
    
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    if( agent.isEposDisplay )  {
        //[agent displayAllingedTextLines:@"" valueStr:@""
                           //itemStr2:EPOSLocalizedString(@"Phonetic_Subtotal", _skinManager.language, nil) valueStr2:_itemManager.phoneticTotal];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if( (int)[def  integerForKey:ePOSDisplayModelKey] != 3 ) { // D70以外の設定
            [agent displayAllingedTextLines:@"" valueStr:@""
                                   itemStr2:EPOSLocalizedString(@"Total", _skinManager.language, nil) valueStr2:_itemManager.total];
        }
    }
}

//
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadata in metadataObjects) {
        //if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            [_session stopRunning];
            _processing = NO;
            NSString *code = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
#ifdef USE_SYSTEMSOUND
            AudioServicesPlaySystemSound(_beepSound);
#else
            [_player play];
#endif
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            [_preview removeFromSuperlayer];
            [_overLay removeFromSuperview];
            _isSessionStart = NO;
            
            _keyboardViewController.scanButton.selected = NO;
            
            if(code) {
                NSString *name = [_dataManager nameFromCode:code];
                if(name.length) {
                    [self addItem:code];
                } else {
                    
                }
            }
        }
    }
}


#pragma mark - gesture handller
- (void)handleTapGesture:(UITapGestureRecognizer*)sender
{
    UIGestureRecognizerState state = sender.state;
    if(state == UIGestureRecognizerStateEnded) {
        //CGPoint pt = [sender locationInView:self.view];
        [self hideSkinSelecctView:0.3];
    }
}

- (void)handleItemTapGesture:(UITapGestureRecognizer*)sender
{
    UIGestureRecognizerState state = sender.state;
    if(state == UIGestureRecognizerStateEnded) {
        [self performSegueWithIdentifier:@"ShowDataSettings" sender:nil];
    }
}

#pragma mark - private
- (void)connect
{
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *ipaddress = [def objectForKey:ePOSDefaultIPAddressKey];
    NSString *printerID = [def objectForKey:ePOSDefaultPrinterIDKey];
    NSString *displayID = [def objectForKey:ePOSDefaultDisplayIDKey];
    NSString *scannerID = [def objectForKey:ePOSDefaultScannerIDKey];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:printerID, @"printerID", displayID, @"displayID", scannerID, @"scannerID", nil];
    _toolbarViewController.connectStatus = ePOSConnectStatusConnecting;
    [agent connectIPAddress:ipaddress  deviceIDs:dic completion:^(int result) {
        if([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
        if(result == EPOS2_SUCCESS) {
            _isIdle = YES;

#if 1
            _toolbarViewController.connectStatus = ePOSConnectStatusConnected;
            if( agent.isEposPrinter ) {
                _toolbarViewController.printerReady = ePOSToolbarIndicatorModeOnline;
            }
            else { _toolbarViewController.printerReady = ePOSToolbarIndicatorModeOffline;
            }
            if( agent.isEposDisplay ) {
                _toolbarViewController.displayReady = ePOSToolbarIndicatorModeOnline;
            }
            else {
                _toolbarViewController.displayReady = ePOSToolbarIndicatorModeOffline;
            }
            if( agent.isEposScanner ) {
                _toolbarViewController.scannerReady = ePOSToolbarIndicatorModeOnline;
            }
            else {
                _toolbarViewController.scannerReady = ePOSToolbarIndicatorModeOffline;
            }
            
            if( agent.isEposScanner ) [self performSelector:@selector(startScanner)];
            
            _connected = YES;

#else
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                while(!agent.isEposPrinter || !agent.isEposDisplay || !agent.isEposScanner ) {
                    [NSThread sleepForTimeInterval:0.05];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    controller.connectStatus = ePOSConnectStatusConnected;
                    _connected = YES;
                    NSLog(@"Connected");
                });
            });
#endif

        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:ePOSDisconnectNotification object:self];
            if(_connected == YES)
            {
                NSString *message = [ePOSErrorMessage message:result];
                if(message.length) {
                    IWUIAlertView *alert =
                    [[IWUIAlertView alloc] initWithTitle:EPOSLocalizedString(@"Connect error!", _skinManager.language, nil)
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                       otherButtonTitles:nil, nil];
                    [alert showWithCompletionHandler:^(NSInteger button){}];
                }
            }
            //[_idleTimer invalidate];
            //_idleTimer = nil;
            _isIdle = NO;
            _connected = NO;
            _toolbarViewController.connectStatus = ePOSConnectStatusDisconnect;
            _toolbarViewController.printerReady = ePOSToolbarIndicatorModeOffline;
            _toolbarViewController.displayReady = ePOSToolbarIndicatorModeOffline;
            _toolbarViewController.scannerReady = ePOSToolbarIndicatorModeOffline;
            _toolbarViewController.keyboardReady = ePOSToolbarIndicatorModeOffline;
        }
    }];
}

- (void)disconnect
{
    //[_idleTimer invalidate];
    //_idleTimer = nil;
    _isIdle = NO;
    _connected = NO;
    _toolbarViewController.connectStatus = ePOSConnectStatusConnecting;
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    [agent disconnectCompletion:^(int result) {
        _toolbarViewController.connectStatus = ePOSConnectStatusDisconnect;
        _toolbarViewController.printerReady = ePOSToolbarIndicatorModeOffline;
        _toolbarViewController.displayReady = ePOSToolbarIndicatorModeOffline;
        _toolbarViewController.scannerReady = ePOSToolbarIndicatorModeOffline;
        _toolbarViewController.keyboardReady = ePOSToolbarIndicatorModeOffline;
    }];
}

- (ePOSConnectStatus)connectStatus
{
    return _toolbarViewController.connectStatus;
}

- (void)showSkinSelectView
{
    _processing = YES;
    _skinSelectView.alpha = 0.;
    _skinSelectView.hidden = NO;
    [self.view bringSubviewToFront:_skinSelectView];
    
    [UIView animateWithDuration:.3 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _skinSelectView.alpha = 1.;
    } completion:^(BOOL finished) {
        _processing = NO;
    }];
}

- (void)hideSkinSelecctView:(NSTimeInterval)dulation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ePOSChangeSkinNotification object:self];
    [UIView animateWithDuration:dulation delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _skinSelectView.alpha = 0.;
    } completion:^(BOOL finished) {
        _skinSelectView.alpha = 0.;
        _skinSelectView.hidden = YES;
        [self.view sendSubviewToBack:_skinSelectView];
    }];
}

- (void)showCardView
{
    _processing = YES;
    _cardSignPhase = 0;
    UINib *nib = [UINib nibWithNibName:@"CardView" bundle:nil];
    _cardView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    _cardView.alpha = 0.;
    [self.view addSubview:_cardView];
    [UIView animateWithDuration:0.3 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _cardView.alpha = 1.;
    } completion:^(BOOL finished) {
        _processing = NO;
        [_cardView setupTarget:self action:@selector(pushCard:)];
    }];
}

- (void)hideCardView
{
    [UIView animateWithDuration:0.1 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _cardView.alpha = 0.;
    } completion:^(BOOL finished) {
        [_cardView removeFromSuperview];
    }];
}

- (void)initCaptureDevice
{
#if HAS_AVFF
    _session = [[AVCaptureSession alloc] init];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = nil;
    AVCaptureDevicePosition camera = AVCaptureDevicePositionBack; // Back or Front
    for (AVCaptureDevice *d in devices) {
        device = d;
        if (d.position == camera) {
            break;
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    [_session addInput:input];
    
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:output];
    
    
    output.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                                   AVMetadataObjectTypeCode39Code,
                                   AVMetadataObjectTypeCode39Mod43Code,
                                   AVMetadataObjectTypeEAN13Code,
                                   AVMetadataObjectTypeEAN8Code,
                                   AVMetadataObjectTypeCode93Code,
                                   AVMetadataObjectTypeCode128Code,
                                   AVMetadataObjectTypePDF417Code,
                                   AVMetadataObjectTypeQRCode,
                                   AVMetadataObjectTypeAztecCode];
    
    CGRect rect = _itemView.frame;
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.frame = CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
    _preview.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat angle = 90.;
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        angle = -90.;
    }
    _preview.affineTransform = CGAffineTransformMakeRotation(angle * M_PI / 180.);
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _overLay = [[ePOSOverlayView alloc] initWithFrame:_preview.frame];
    
    NSURL *sound = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beep" ofType:@"aiff"] isDirectory:NO];
#ifdef USE_SYSTEMSOUND
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)sound, &_beepSound);
#else
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:sound error:nil];
    [_player prepareToPlay];
#endif
    
#endif
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat angle = 90.;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        angle = -90.;
    }
    _preview.affineTransform = CGAffineTransformMakeRotation(angle * M_PI / 180.);

}

- (void)showScanQuantityView
{
    _scanQuantityView.quantity = _itemManager.currentQuantity;
    _scanQuantityView.center = CGPointMake(self.view.center.y, self.view.center.x);
    [self.view bringSubviewToFront:_scanQuantityView];
    [UIView animateWithDuration:0.1 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _scanQuantityView.alpha = 1.;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _scanQuantityView.alpha = 0.;
        } completion:^(BOOL finished) {
        }];
    }];

}

- (void)addItem:(NSString *)code
{
    // change Accounting State to Accounting(2)
    AccountingFlg = 2;
    if(_keyboardMode == ePOSKeyboardModeNormal || _keyboardMode == ePOSKeyboardModeNone || _keyboardMode == ePOSKeyboardModeIemCode) {
        NSString *name = [_dataManager nameFromCode:code];
        if(name.length) {
            [_itemManager addItemCode:code quantity:_itemManager.currentQuantity];
            [_itemViewController addItem];
            [_totalViewController updateTotal];
            _itemManager.currentQuantity = 1;
            _quantityClearFlag = YES;
            
            NSInteger index = [_itemViewController selectedIndex];
            NSString *item = [_itemManager phoneticAtIndex:index];
            NSString *price = [_itemManager phoneticPriceAtIndex:index];
            ePOSAgent *agent = [ePOSAgent sharedAgent];
            if( agent.isEposDisplay ) {
                
            [agent displayAllingedTextLines:item valueStr:price
                                   itemStr2:EPOSLocalizedString(@"Subtotal", _skinManager.language, nil) valueStr2:_itemManager.phoneticTotal];

                
            }
            _isIdle = NO;
            
            _keyboardMode = ePOSKeyboardModeNormal;
            _keyboardViewController.keyBoardMode = _keyboardMode;
            _itemViewController.keyBoardMode = _keyboardMode;
        } else {
            
        }
    }
}


- (void)printReceipt
{
    _keyboardMode = ePOSKeyboardModeNormal;
    
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if( agent.isEposDisplay )  {
        if( (int)[ def integerForKey:ePOSDisplayModelKey] != 3 ) { // D70以外の設定
            [agent displayAllingedTextLines:EPOSLocalizedString(@"Deposit", _skinManager.language, nil) valueStr:_itemManager.phoneticDeposit
                               itemStr2:EPOSLocalizedString(@"Change", _skinManager.language, nil) valueStr2:_itemManager.phoneticChange];
        }
        else {
            [agent displayAllingedTextLines:@"お預り" depositValue:_itemManager.phoneticDeposit totalAmount:@"お買上" totalAmountValue:_itemManager.phoneticTotal dispence:@"お釣り" dispenseValue:_itemManager.phoneticChange];
        }
        
        
    }

    _isIdle = YES;
    BOOL _isCard = _signArray == nil ? NO : YES;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    ePOSPrintManager *printManager = [[ePOSPrintManager alloc] init];
    
    //add 2018/3/1
    Boolean memberID = true;
    if([[_itemViewController getMemberID] isEqualToString:@""]){
        memberID = false;
    }
    //end 2018/3/1
    
    _taxForTaxFree = _itemManager.tax;
    _netForTaxFree = _itemManager.net;
    
    [printManager printReceipt:memberID :_signArray completion:^(Epos2Printer* printerObj,int code, Epos2PrinterStatusInfo* status, NSString* printJobId) {
        if(code == EPOS2_CODE_SUCCESS) {
            [self performSelector:@selector(clearItems) withObject:nil afterDelay:1.];
            [_itemManager addCSV:_signArray];
        } else {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            NSString *message = [ePOSErrorMessage message:code];
            if(message.length) {
                IWUIAlertView *alert =
                [[IWUIAlertView alloc] initWithTitle:EPOSLocalizedString(@"Print Error!", _skinManager.language, nil)
                                             message:message
                                            delegate:nil
                                   cancelButtonTitle:EPOSLocalizedString(@"OK", _skinManager.language, nil)
                                   otherButtonTitles:nil, nil];
                [alert showWithCompletionHandler:^(NSInteger button){
                    if(_isCard) {
                        [self clearItems];
                    } else {
                        _keyboardMode = ePOSKeyboardModeDeposit;
                    }
              }];
            }
        }
        _signArray = nil;
    }];

}

// Add start 2018/3/1
- (void)printTaxFree{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    ePOSPrintManager *printManager = [[ePOSPrintManager alloc] init];
    
    [printManager printTaxFree:_taxForTaxFree :_netForTaxFree completion:^(Epos2Printer* printerObj,int code, Epos2PrinterStatusInfo* status, NSString* printJobId) {
        if(code == EPOS2_CODE_SUCCESS) {
            [self performSelector:@selector(clearItems) withObject:nil afterDelay:1.];
            [_itemManager addCSV:_signArray];
        } else {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            NSString *message = [ePOSErrorMessage message:code];
            if(message.length) {
                IWUIAlertView *alert =
                [[IWUIAlertView alloc] initWithTitle:EPOSLocalizedString(@"Print Error!", _skinManager.language, nil)
                                             message:message
                                            delegate:nil
                                   cancelButtonTitle:EPOSLocalizedString(@"OK", _skinManager.language, nil)
                                   otherButtonTitles:nil, nil];
                [alert showWithCompletionHandler:^(NSInteger button){
                }];
            }
        }
        _signArray = nil;
    }];
}
// Add end 2018/3/1

- (void)clearItems
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [_totalViewController updateChange];
    _totalViewController.depositMode = NO;
    _keyboardMode = ePOSKeyboardModeNone;
    _keyboardViewController.keyBoardMode = _keyboardMode;
    [_itemViewController removeAllItems];
    [_totalViewController updateAll];
}
@end
