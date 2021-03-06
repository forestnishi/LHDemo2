//
//  ePOSDataSettingsTableViewController.h
//  ePOS
//
//  Created by komatsu on 2014/07/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ePOSDataSettingsManager.h"
#import "ePOSDataSettingsItemViewController.h"
#import "ePOSDataSettingsProductTableViewController.h"

extern NSString * const ePOSRemoveAllItemsNotification;


@interface ePOSDataSettingsTableViewController : UITableViewController
<ePOSDataSettingsProductTableViewControllerDelegate>

@property (nonatomic) ePOSDataSettingsManager *dataSettingsManager;

@property (nonatomic) ePOSDataSettingsItemViewController *settinsItemController;

@end
