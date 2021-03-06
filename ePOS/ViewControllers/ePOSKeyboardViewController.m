//
//  ePOSKeyboardViewController.m
//  ePOS
//
//  Created by komatsu on 2014/06/16.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ePOSKeyboardViewController.h"
#import "ePOSSkinManager.h"

#define USE_SYSTEMSOUND 1

#define SLEEP 0

@interface ePOSKeyboardViewController ()

@end

@implementation ePOSKeyboardViewController
{
#if USE_SYSTEMSOUND
    SystemSoundID _beepSound;
    SystemSoundID _silentSound;
    NSTimer *_timer;
#else
    AVAudioPlayer *_player;
#endif
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self redrawView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawView) name:ePOSChangeSkinNotification object:nil];
    
    NSURL *sound = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"epos2-4" ofType:@"aiff"] isDirectory:NO];
    NSURL *silentSound = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"epos2Silent" ofType:@"aiff"] isDirectory:NO];
#if USE_SYSTEMSOUND
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)sound, &_beepSound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)silentSound, &_silentSound);
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(silentPlay) userInfo:nil repeats:YES];
    [_timer fire];


#else
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:sound error:nil];
    [_player prepareToPlay];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)redrawView
{
//    ePOSSkinManager *manager = [ePOSSkinManager sharedSkinManager];
//    self.view.backgroundColor = manager.backgroundColor;
//    [self.view setNeedsDisplay];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pushCard:(UIButton *)sender
{
    if ( [self.delegate respondsToSelector:@selector(ePOSKeyboardViewControllerDidSelectCard:)] ) {
        [self.delegate ePOSKeyboardViewControllerDidSelectCard:self];
    }
    [self playSound];
}

- (IBAction)pushCash:(UIButton *)sender
{
    if ( [self.delegate respondsToSelector:@selector(ePOSKeyboardViewControllerDidSelectCash:)] ) {
        [self.delegate ePOSKeyboardViewControllerDidSelectCash:self];
    }
    [self playSound];
}

- (IBAction)pushScan:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ( [self.delegate respondsToSelector:@selector(ePOSKeyboardViewControllerDidSelectScanner:)] ) {
        [self.delegate ePOSKeyboardViewControllerDidSelectScanner:self];
    }

}

- (IBAction)pushNumber:(UIButton *)sender
{
    if ( [self.delegate respondsToSelector:@selector(ePOSKeyboardViewController:didSelectNumber:)] ) {
        [self.delegate ePOSKeyboardViewController:self didSelectNumber:sender.tag];
    }
    [self playSound];
}

- (IBAction)pushControl:(UIButton *)sender
{
    if ( [self.delegate respondsToSelector:@selector(ePOSKeyboardViewController:didSelectControl:)] ) {
        [self.delegate ePOSKeyboardViewController:self didSelectControl:sender.tag];
    }
    [self playSound];

}

- (void)setKeyBoardMode:(ePOSKeyboardMode)keyBoardMode
{
    if(keyBoardMode == ePOSKeyboardModeNormal) {
        _cashButton.enabled = YES;
        _cardButton.enabled = YES;
        _scanButton.enabled = YES;
    } else if(keyBoardMode == ePOSKeyboardModeDeposit) {
        _cashButton.enabled = NO;
        _cardButton.enabled = YES;
        _scanButton.enabled = NO;
    } else if(keyBoardMode == ePOSKeyboardModeIemCode) {
        _cashButton.enabled = NO;
        _cardButton.enabled = NO;
        _scanButton.enabled = NO;
    } else {
        _cashButton.enabled = NO;
        _cardButton.enabled = NO;
        _scanButton.enabled = YES;
    }
}


- (void)playSound
{
#if USE_SYSTEMSOUND
    
    AudioServicesPlaySystemSound(_beepSound);

#else
    [_player stop];
    [_player play];
#endif

}

- (void)silentPlay
{
    AudioServicesPlayAlertSound(_silentSound);
}
@end
