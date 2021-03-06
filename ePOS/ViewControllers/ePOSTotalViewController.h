//
//  ePOSTotalViewController.h
//  ePOS
//
//  Created by komatsu on 2014/06/17.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ePOSTotalBaseView;


@interface ePOSTotalViewController : UIViewController

@property (nonatomic, weak) IBOutlet ePOSTotalBaseView *totalView;
@property (nonatomic, weak) IBOutlet UILabel *totalLabel;
@property (nonatomic, weak) IBOutlet UILabel *depositLabel;
@property (nonatomic, weak) IBOutlet UILabel *changeLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalValue;
@property (nonatomic, weak) IBOutlet UILabel *depositValue;
@property (nonatomic, weak) IBOutlet UILabel *changeValue;
@property (nonatomic, weak) IBOutlet UIView *depositHilightView;

@property (nonatomic) BOOL depositMode;

- (void)updateAll;
- (void)updateTotal;
- (void)pushKeyboard:(NSInteger)number;
- (void)updateDeposit;
- (void)clearDeposit;
- (void)updateChange;

@end

