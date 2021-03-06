//
//  ePOSItemViewController.h
//  ePOS
//
//  Created by komatsu on 2014/06/17.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ePOSKeyboardViewController.h"

@protocol ePOSItemViewControllerDelegate;

@interface ePOSItemViewController : UIViewController

@property(nonatomic, weak) id<ePOSItemViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UILabel *itemLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *qtyLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtotalLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtotalValue;
@property (nonatomic, weak) IBOutlet UILabel *itemCodeLabel;
@property (nonatomic, weak) IBOutlet UIButton *codeButton;
@property (nonatomic, weak) IBOutlet UIView *itemTitleBar;
@property (nonatomic, weak) IBOutlet UIView *itemBackgroundView;
@property (nonatomic, weak) IBOutlet UIView *itemSubtotalView;
@property (nonatomic, weak) IBOutlet UILabel *itemCodeValue;
@property (nonatomic, weak) IBOutlet UIButton *itemRemoveButton;
@property (nonatomic, weak) IBOutlet UIButton *itemAllRemoveButton;

@property (nonatomic, weak) IBOutlet UIImageView *itemTitleBarImage;

@property (nonatomic) ePOSKeyboardMode keyBoardMode;

- (IBAction)pushCodeButton:(id)sender;
- (IBAction)pushRemoveItem:(id)sender;
- (IBAction)pushRemoveAllItems:(id)sender;

- (void)addItem;
- (void)updateQuantity:(BOOL)incriment;
- (NSInteger)selectedIndex;
- (void)removeAllItems;

- (void)pushKeyboard:(NSInteger)number;
- (void)clearItemCode;
- (void)setMemberID:(NSString*) scanData;
- (NSString* )getMemberID;

@end

@protocol ePOSItemViewControllerDelegate <NSObject>
@optional

- (void)ePOSItemViewController:(ePOSItemViewController *)ePOSItemViewController didSelectItemCode:(BOOL)mode;
- (void)ePOSItemViewController:(ePOSItemViewController *)ePOSItemViewController addItem:(NSString *)code;
- (void)ePOSItemViewControllerDidUpdateItems:(ePOSItemViewController *)ePOSItemViewController;
@end
