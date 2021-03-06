//
//  ePOSSettingsTableViewController.h
//  ePOS
//
//  Created by komatsu on 2014/06/23.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ePOSViewController.h"

extern NSString * const ePOSDisconnectNotification;

@interface ePOSSettingsTableViewController : UITableViewController



@property (nonatomic, weak) IBOutlet UITextField *ipAddressField;
@property (nonatomic, weak) IBOutlet UITextField *printerIDField;
@property (nonatomic, weak) IBOutlet UITextField *displayIDField;
@property (nonatomic, weak) IBOutlet UITextField *scannerIDField;

@property (nonatomic, weak) IBOutlet UISegmentedControl *connectSegment;
@property (nonatomic, weak) IBOutlet UISegmentedControl *paperWidthSegment;
@property (nonatomic, weak) IBOutlet UISegmentedControl *printColumnSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *DisplayModelSegment;

@property (nonatomic, weak) IBOutlet UIButton *printerButton;
@property (nonatomic, weak) IBOutlet UIButton *scannerButton;
@property (nonatomic, weak) IBOutlet UIButton *displayButton;
@property (nonatomic, weak) IBOutlet UIButton *keyboardButton;

@property (nonatomic, weak) IBOutlet UILabel *printerStatus;
@property (nonatomic, weak) IBOutlet UILabel *scannerStatus;
@property (nonatomic, weak) IBOutlet UILabel *displayStatus;
@property (nonatomic, weak) IBOutlet UILabel *keyboardStatus;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, weak) ePOSViewController *viewController;


- (IBAction)pushConnect:(id)sender;
- (IBAction)pushPaperWidth:(id)sender;
- (IBAction)pushColumn:(id)sender;
- (IBAction)pushPrinter:(id)sender;
- (IBAction)pushScanner:(id)sender;
- (IBAction)pushDisplay:(id)sender;
- (IBAction)pushKeyboard:(id)sender;
- (IBAction)selectDisplayModel:(id)sender;

@end
