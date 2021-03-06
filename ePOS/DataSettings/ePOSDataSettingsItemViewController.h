//
//  ePOSDataSettingsItemViewController.h
//  ePOS
//
//  Created by komatsu on 2014/06/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ePOSDataSettingsManager.h"

@protocol ePOSDataSettingsItemViewControllerDelegate;

@interface ePOSDataSettingsItemViewController : UITableViewController

@property(nonatomic, weak) id<ePOSDataSettingsItemViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITextField *productCode;
@property (nonatomic, weak) IBOutlet UITextField *nameEnglish;
@property (nonatomic, weak) IBOutlet UITextField *nameJapanese;
@property (nonatomic, weak) IBOutlet UITextField *displayNameEnglish;
@property (nonatomic, weak) IBOutlet UITextField *displayNameJapanese;
@property (nonatomic, weak) IBOutlet UITextField *price;
@property (nonatomic, weak) IBOutlet UITextField *imageName;

@property (nonatomic, weak) IBOutlet UILabel *productCodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameEnblishLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameJapaneseLabel;
@property (nonatomic, weak) IBOutlet UILabel *displayNameEnglishLabel;
@property (nonatomic, weak) IBOutlet UILabel *displayNameJapaneseLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *imageLabel;

@property (nonatomic) ePOSDataSettingsManager *dataSettingsManager;

- (IBAction)pushDone:(id)sender;
- (IBAction)pushAdd:(id)sender;

- (void)setProductKey:(NSString *)key dictionary:(NSDictionary *)product;
- (void)disable;
- (void)addButtonEnable:(BOOL)enable;

@end

@protocol ePOSDataSettingsItemViewControllerDelegate <NSObject>
@optional
- (void)dataSettingsItemViewController:(ePOSDataSettingsItemViewController *)dataSettingsItemViewController didChangeProduct:(NSDictionary *)product forKey:(NSString *)key;
@end