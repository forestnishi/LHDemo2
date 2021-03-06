//
//  ePOSTotalViewController.m
//  ePOS
//
//  Created by komatsu on 2014/06/17.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSTotalViewController.h"
#import "ePOSSkinManager.h"
#import "ePOSTotalBaseView.h"
#import "ePOSItemManager.h"
#import "ePOSKeyboardViewController.h"

@interface ePOSTotalViewController ()
{
    ePOSSkinManager *_skinManager;
    ePOSItemManager *_itemManager;
    NSInteger _decimalDigit;
}
@end

@implementation ePOSTotalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _skinManager = [ePOSSkinManager sharedSkinManager];
    _itemManager = [ePOSItemManager sharedItemManager];
    
    _itemManager.depositValue = 0;

    _decimalDigit = 0;
    
    [self redrawView];
    

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawView) name:ePOSChangeSkinNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)redrawView
{
    _totalLabel.text = EPOSLocalizedString(@"Total", _skinManager.language, nil);
    _depositLabel.text = EPOSLocalizedString(@"Deposit", _skinManager.language, nil);
    _changeLabel.text = EPOSLocalizedString(@"Change", _skinManager.language, nil);
    _totalValue.text = _itemManager.total;
    _depositValue.text = _itemManager.deposit;
    _changeValue.text = _itemManager.change;
    [_totalView setNeedsDisplay];
}

- (void)updateAll
{
    [self updateTotal];
    [self clearDeposit];
    [self updateChange];
    
}

- (void)updateTotal
{
    _totalValue.text = _itemManager.total;
}

- (void)setDepositMode:(BOOL)depositMode
{
    if(depositMode == YES) {
        _depositHilightView.backgroundColor = [_skinManager hilightColor];
    } else {
        _depositHilightView.backgroundColor = [UIColor clearColor];
    }
}

- (void)pushKeyboard:(NSInteger)number
{
    double num = number;
    if(number == ePOSKeyboardKeyKindPeriod ) {
        if(_skinManager.language == ePOSLanguageEnglish) {
            if(_decimalDigit != 0) return;
            _decimalDigit = 1;
            return;
        } else {
            return;
        }
    }
    if(_decimalDigit >= 3) return;
    
    if(number == ePOSKeyboardKeyKindZeroZero) num = 0;
    
    double value = _itemManager.depositValue;
    //if(value < LLONG_MAX / 10 - 9)
    {
        num = num / pow(10., _decimalDigit);
        NSInteger mul = 10;
        if(_decimalDigit) {
            mul = 1;
            _decimalDigit ++;
        }
        value = value * mul + num;
        if(number == ePOSKeyboardKeyKindZeroZero) {
            if(_decimalDigit == 0) {
                value = value * 10 + num;
            } else {
                _decimalDigit ++;
            }
        }
        _itemManager.depositValue = value;
        _depositValue.text = _itemManager.deposit;
    }
}

- (void)updateDeposit
{
    _depositValue.text = _itemManager.deposit;
    _decimalDigit = 0;
}

- (void)clearDeposit
{
    _itemManager.depositValue = 0;
    [self updateDeposit];
}

- (void)updateChange
{
    _changeValue.text = _itemManager.change;
}

@end
