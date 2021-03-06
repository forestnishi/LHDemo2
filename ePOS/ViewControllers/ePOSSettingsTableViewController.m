//
//  ePOSSettingsTableViewController.m
//  ePOS
//
//  Created by komatsu on 2014/06/23.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSettingsTableViewController.h"
#import "ePOSUserDefault.h"
#import "ePOSAgent.h"
#import "ePOSSkinManager.h"


@interface ePOSSettingsTableViewController ()
{
    NSTimer *_timer;
    BOOL _disconnect;
}
@end

@implementation ePOSSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadParams];

    //_timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(idleProcess) userInfo:nil repeats:YES];

    [[NSNotificationCenter defaultCenter] addObserverForName:ePOSDisconnectNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        _disconnect = YES;
        DEBUG_LOG(@"Settings Disconnect Notification")
    }];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSInteger width = [[def objectForKey:ePOSDefaultPaperWidthKey] integerValue];
    NSInteger col = [[def objectForKey:ePOSDefaultPrintColumnKey] integerValue];
    if(width == 80) {
        _paperWidthSegment.selectedSegmentIndex = 0;
    } else {
        _paperWidthSegment.selectedSegmentIndex = 1;
    }
    
    [self pushPaperWidth:nil];
    
    if(width == 80) {
        _paperWidthSegment.selectedSegmentIndex = 0;
        if(col == 42) {
            _printColumnSegment.selectedSegmentIndex = 1;
        } else {
            _printColumnSegment.selectedSegmentIndex = 0;
        }
    } else {
        _paperWidthSegment.selectedSegmentIndex = 1;
        if(col == 35) {
            _printColumnSegment.selectedSegmentIndex = 2;
        } else if(col == 34) {
            _printColumnSegment.selectedSegmentIndex = 1;
        } else {
            _printColumnSegment.selectedSegmentIndex = 0;
        }
    }
}

- (void)dealloc
{
    if(_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)pushConnect:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0) {  // connect
        _disconnect = NO;
        [_indicator startAnimating];
        [_viewController connect];

    } else {
        [_indicator stopAnimating];
        [_viewController disconnect];
    }
}

- (IBAction)pushPaperWidth:(id)sender
{
    if(_paperWidthSegment.selectedSegmentIndex == 0) {  // 80mm
        if(_printColumnSegment.numberOfSegments != 2) {
            if(_printColumnSegment.selectedSegmentIndex == 2) {
                _printColumnSegment.selectedSegmentIndex = 0;
            }
            [_printColumnSegment setTitle:@"42" forSegmentAtIndex:0];
            [_printColumnSegment setTitle:@"48" forSegmentAtIndex:1];
            [_printColumnSegment removeSegmentAtIndex:2 animated:YES];
        }
    } else {                                            // 58mm
        if(_printColumnSegment.numberOfSegments != 3) {
            [_printColumnSegment setTitle:@"30" forSegmentAtIndex:0];
            [_printColumnSegment setTitle:@"34" forSegmentAtIndex:1];
            [_printColumnSegment insertSegmentWithTitle:@"35" atIndex:3 animated:YES];
        }
    }
}

- (IBAction)pushColumn:(id)sender;
{
}

- (IBAction)pushPrinter:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (IBAction)pushScanner:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (IBAction)pushDisplay:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (IBAction)pushKeyboard:(UIButton *)sender
{
    sender.selected = !sender.selected;
}



#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 2) {
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        
        NSString *version;
        if( (version = [info objectForKey:@"CFBundleShortVersionString"] ) == nil )
            version = [info objectForKey:@"CFBundleVersion"];
        return  [NSString stringWithFormat:@"Copyright(C) 2014 Seiko Epson Corp 2014. All rights reserved.\nVersion %@", version];
    }
    return nil;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushApply"]) {
        [self saveParams];
    }
    [_timer invalidate];
    _timer = nil;
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

#pragma mark - private
- (void)loadParams
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    _ipAddressField.text = [def objectForKey:ePOSDefaultIPAddressKey];
    _printerIDField.text = [def objectForKey:ePOSDefaultPrinterIDKey];
    _displayIDField.text = [def objectForKey:ePOSDefaultDisplayIDKey];
    _scannerIDField.text = [def objectForKey:ePOSDefaultScannerIDKey];
    
    _printerButton.selected = [[def objectForKey:ePOSDefaultValidPrinterKey] boolValue];
    _scannerButton.selected = [[def objectForKey:ePOSDefaultValidScannerKey] boolValue];
    _displayButton.selected = [[def objectForKey:ePOSDefaultValidDisplayKey] boolValue];
    _keyboardButton.selected = [[def objectForKey:ePOSDefaultValidKeyboardKey] boolValue];
    
    if( [def integerForKey:ePOSDisplayModelKey] == 3 ) {
        
        if( [def integerForKey:ePOSDisplayViewKey] == 0 ) {
            // この場合 DM-D70 横置き
            _DisplayModelSegment.selectedSegmentIndex = 4;
            // D70を指定する
            isDisplayLandscape = TRUE;
        }
        else {
            // この場合 DM-D70 縦置き
            _DisplayModelSegment.selectedSegmentIndex = 3;
            // D70を指定する
            isDisplayLandscape = FALSE;
        }
    }
    else _DisplayModelSegment.selectedSegmentIndex = [def integerForKey:ePOSDisplayModelKey];
  
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
 
    if( isPrinterConnected ) {
        _connectSegment.selectedSegmentIndex = 0;
        _printerStatus.text = EPOSLocalizedString(@"Status:Connect", skinManager.language, nul);
    }
    else {
        _connectSegment.selectedSegmentIndex = 1;
        _printerStatus.text = EPOSLocalizedString(@"Status:Disconnect", skinManager.language, nul);
    }
}

- (void)saveParams
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if(_ipAddressField.text.length) {
        [def setObject:_ipAddressField.text forKey:ePOSDefaultIPAddressKey];
    } else {
        [def removeObjectForKey:ePOSDefaultIPAddressKey];
    }
    
    if(_printerIDField.text.length) {
        [def setObject:_printerIDField.text forKey:ePOSDefaultPrinterIDKey];
    } else {
        [def removeObjectForKey:ePOSDefaultPrinterIDKey];
    }
    
    if(_displayIDField.text.length) {
        [def setObject:_displayIDField.text forKey:ePOSDefaultDisplayIDKey];
    } else {
        [def removeObjectForKey:ePOSDefaultDisplayIDKey];
    }
    
    if(_scannerIDField.text.length) {
        [def setObject:_scannerIDField.text forKey:ePOSDefaultScannerIDKey];
    } else {
        [def removeObjectForKey:ePOSDefaultScannerIDKey];
    }
    
    [def setObject:@(_printerButton.selected) forKey:ePOSDefaultValidPrinterKey];
    [def setObject:@(_scannerButton.selected) forKey:ePOSDefaultValidScannerKey];
    [def setObject:@(_displayButton.selected) forKey:ePOSDefaultValidDisplayKey];
    [def setObject:@(_keyboardButton.selected) forKey:ePOSDefaultValidKeyboardKey];
    
    if(_paperWidthSegment.selectedSegmentIndex == 0) {  // 80mm
        [def setObject:@(80) forKey:ePOSDefaultPaperWidthKey];
    } else {                                            // 58mm
        [def setObject:@(58) forKey:ePOSDefaultPaperWidthKey];
    }

    NSInteger col;
    if(_paperWidthSegment.selectedSegmentIndex == 0) {
        if(_printColumnSegment.selectedSegmentIndex == 0) {
            col = 48;
        } else {
            col = 42;
        }
    } else {
        if(_printColumnSegment.selectedSegmentIndex == 0) {
            col = 30;
        } else if(_printColumnSegment. selectedSegmentIndex == 1) {
            col = 34;
        } else {
            col = 35;
        }
    }
    [def setObject:@(col) forKey:ePOSDefaultPrintColumnKey];
    
    if( _DisplayModelSegment.selectedSegmentIndex == 3 ) {
        [def setInteger:3 forKey:ePOSDisplayModelKey]; // DM-D70を指定する
        [def setInteger:1 forKey:ePOSDisplayViewKey]; // Portlate
        isDisplayLandscape = FALSE;
    }
    else if( _DisplayModelSegment.selectedSegmentIndex == 4 ) {
        [def setInteger:3 forKey:ePOSDisplayModelKey]; // DM-D70を指定する
        [def setInteger:0 forKey:ePOSDisplayViewKey]; // Landscape
        isDisplayLandscape = TRUE;
    }
    else {
        [def setInteger:_DisplayModelSegment.selectedSegmentIndex forKey:ePOSDisplayModelKey]; //スライドスイッチの番号のとおり設定する
        [def setInteger:0 forKey:ePOSDisplayViewKey]; // Landscape
    }
}

- (void)idleProcess
{
    ePOSAgent *agent = [ePOSAgent sharedAgent];
    
    if(_viewController.connectStatus == ePOSConnectStatusConnecting) {
        [_indicator startAnimating];
        _connectSegment.enabled = NO;
    } else {
        _connectSegment.enabled = YES;
        [_indicator stopAnimating];
        
    }
    
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    if( isPrinterConnected == TRUE ) {
        _printerStatus.text = EPOSLocalizedString(@"Status : Connect", skinManager.language, nil);
    } else {
        _printerStatus.text = EPOSLocalizedString(@"Status : Disconnect", skinManager.language, nil);
    }
    if(isDisplayConnected) {
        _displayStatus.text = EPOSLocalizedString(@"Status : Connect", skinManager.language, nil);
    } else {
        _displayStatus.text = EPOSLocalizedString(@"Status : Disconnect", skinManager.language, nil);
    }
    if(isScannerConnected) {
        _scannerStatus.text = EPOSLocalizedString(@"Status : Connect", skinManager.language, nil);
    } else {
        _scannerStatus.text = EPOSLocalizedString(@"Status : Disconnect", skinManager.language, nil);
    }
    
}


- (IBAction)selectDisplayModel:(id)sender {
    // nothing to do
}
@end
