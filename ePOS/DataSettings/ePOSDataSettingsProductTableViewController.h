//
//  ePOSDataSettingsProductTableViewController.h
//  ePOS
//
//  Created by komatsu on 2014/07/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ePOSDataSettingsItemViewController.h"
#import "ePOSDataSettingsManager.h"

@protocol ePOSDataSettingsProductTableViewControllerDelegate;

@interface ePOSDataSettingsProductTableViewController : UITableViewController
<ePOSDataSettingsItemViewControllerDelegate>

@property(nonatomic, weak) id<ePOSDataSettingsProductTableViewControllerDelegate> delegate;

@property (nonatomic) NSDictionary *products;
@property (nonatomic) ePOSDataSettingsManager *dataSettingsManager;

@property (nonatomic, weak) ePOSDataSettingsItemViewController *settinsItemController;

@end

@protocol ePOSDataSettingsProductTableViewControllerDelegate <NSObject>
@optional
- (void)dataSettingsProductTableViewController:(ePOSDataSettingsProductTableViewController *)dataSettingsProductTableViewController didChangeProduct:(NSDictionary *)products;
@end