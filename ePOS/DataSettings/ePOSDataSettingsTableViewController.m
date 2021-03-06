//
//  ePOSDataSettingsTableViewController.m
//  ePOS
//
//  Created by komatsu on 2014/07/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSDataSettingsTableViewController.h"
#import "ePOSDataSettingsProductTableViewController.h"
#import "ePOSSplitViewController.h"
#import "ePOSPrintManager.h"
#import "IWUIAlertView.h"
#import "ePOSSkinManager.h"
#import "ePOS2.h"
#import "ePOSUserDefault.h"
#import "ePOSDataManager.h"
#import "ePOSErrorMessage.h"

NSString * const ePOSRemoveAllItemsNotification         = @"ePOSRemoveAllItemsNotification";

@interface ePOSDataSettingsTableViewController ()

@end

@implementation ePOSDataSettingsTableViewController
{
    NSInteger   _currentIndex;
}
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
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pushDone:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    UIBarButtonItem *printButton = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStylePlain target:self action:@selector(pushPrint)];
    self.navigationItem.rightBarButtonItem = printButton;

    [self setDefault];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)pushDone:(id)sender
{
    ePOSDataManager *dataManager = [ePOSDataManager sharedDataManager];
    if([dataManager setCurrentData]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ePOSRemoveAllItemsNotification object:self];
    }
    
    ePOSSplitViewController *splitViewController = (ePOSSplitViewController *)self.splitViewController;
    [splitViewController closeViewController];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSettingsManager.fileCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileNameCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[_dataSettingsManager fileNameAtIndex:indexPath.row] stringByDeletingPathExtension];
    NSString *defaultName = [[NSUserDefaults standardUserDefaults] objectForKey:ePOSCurrentProductFileKey];
    NSString *name = [_dataSettingsManager fileNameAtIndex:indexPath.row];
    if([defaultName isEqualToString:name]) {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.imageView.image = [UIImage imageNamed:@"defaultCheck"];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.imageView.image = [UIImage imageNamed:@"defaultCheckNone"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = [_dataSettingsManager fileNameAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:ePOSCurrentProductFileKey];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_dataSettingsManager removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
    [self setDefault];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self setDefault];
}


#pragma mark - delegate

- (void)dataSettingsProductTableViewController:(ePOSDataSettingsProductTableViewController *)dataSettingsProductTableViewController didChangeProduct:(NSDictionary *)products;
{
    [_dataSettingsManager writeObjectAtIndex:products atIndex:_currentIndex];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    _currentIndex = indexPath.row;
    
    ePOSDataSettingsProductTableViewController *controller = segue.destinationViewController;
    controller.products = [_dataSettingsManager dictionaryAtIndex:_currentIndex];
    controller.title = [[_dataSettingsManager fileNameAtIndex:_currentIndex] stringByDeletingPathExtension];
    controller.settinsItemController = _settinsItemController;
    controller.dataSettingsManager = _dataSettingsManager;
    controller.delegate = self;
}

- (void)pushPrint
{
    NSString *defaultName = [[NSUserDefaults standardUserDefaults] objectForKey:ePOSCurrentProductFileKey];
    NSString *path = [_dataSettingsManager containsFileNmae:defaultName];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

    ePOSPrintManager *printManager = [[ePOSPrintManager alloc] init];
    [printManager printBarcode:dict completion:^(Epos2Printer* printerObj,int code, Epos2PrinterStatusInfo* status, NSString* printJobId){
        if(code == EPOS2_CODE_SUCCESS) {
        } else {
            if(code != EPOS2_ERR_PARAM) {
                ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
                NSString *message = [ePOSErrorMessage message:code];
                if(message.length) {
                    IWUIAlertView *alert =
                    [[IWUIAlertView alloc] initWithTitle:EPOSLocalizedString(@"Print Error!", skinManager.language, nil)
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:EPOSLocalizedString(@"OK", skinManager.language, nil)
                                       otherButtonTitles:nil, nil];
                    [alert showWithCompletionHandler:^(NSInteger button){
                    }];
                }
            }
        }
    }];
}

- (void)setDefault
{
    NSString *defaultName = [[NSUserDefaults standardUserDefaults] objectForKey:ePOSCurrentProductFileKey];
    if([_dataSettingsManager containsFileNmae:defaultName] == nil) {
        NSString *name = [_dataSettingsManager fileNameAtIndex:0];
        if(name) {
            [[NSUserDefaults standardUserDefaults] setObject:name forKey:ePOSCurrentProductFileKey];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ePOSCurrentProductFileKey];
        }
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    }
}

@end
