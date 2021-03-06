//
//  ePOSItemViewController.m
//  ePOS
//
//  Created by komatsu on 2014/06/17.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSItemViewController.h"
#import "ePOSSkinManager.h"
#import "ePOSDataManager.H"
#import "ePOSItemManager.h"
#import "IWUIAlertView.h"
#import "ePOSKeyboardViewController.h"
#import "ePosDataSettingsTableViewController.h"

@interface ePOSItemViewController ()
{
    ePOSSkinManager *_skinManager;
    ePOSDataManager *_dataManager;
    ePOSItemManager *_itemManager;
    NSString *_itemCode;
}

@end

@implementation ePOSItemViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _dataManager = [ePOSDataManager sharedDataManager];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _skinManager = [ePOSSkinManager sharedSkinManager];
    _itemManager = [ePOSItemManager sharedItemManager];

    _itemCode = @"";
    
    [self redrawView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawView) name:ePOSChangeSkinNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ePOSRemoveAllItemsNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self removeAllItems];
        DEBUG_LOG(@"removeAllItems Notification")
    }];
    
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    self.view.backgroundColor = _skinManager.backgroundColor;
    UIImage *image = _skinManager.backgroundImage;
    if(image) {
        self.view.layer.contents = (__bridge id)(image.CGImage);
    } else {
        self.view.layer.contents = nil;
    }
    [self.view setNeedsDisplay];
    
    _itemLabel.text = EPOSLocalizedString(@"Item", _skinManager.language, nil);
    _itemLabel.textColor = _skinManager.itemTitleColor;
    _priceLabel.text = EPOSLocalizedString(@"Price", _skinManager.language, nil);
    _priceLabel.textColor = _skinManager.itemTitleColor;
    _qtyLabel.text = EPOSLocalizedString(@"Qty.", _skinManager.language, nil);
    _qtyLabel.textColor = _skinManager.itemTitleColor;
    _amountLabel.text = EPOSLocalizedString(@"Amount", _skinManager.language, nil);
    _amountLabel.textColor = _skinManager.itemTitleColor;
    _subtotalLabel.text = EPOSLocalizedString(@"Subtotal", _skinManager.language, nil);
    //_itemCodeLabel.text = EPOSLocalizedString(@"Item Code", _skinManager.language, nil);
    
    //_itemTitleBar.layer.contents = (__bridge id)(_skinManager.itemTitleBarImage.CGImage);
    _itemTitleBarImage.image = _skinManager.itemTitleBarImage;
    
    _codeButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];

    [_itemBackgroundView setNeedsDisplay];
    _itemSubtotalView.backgroundColor = _skinManager.itemSubtotalBackgroundColor;
    //[_itemSubtotalView setNeedsDisplay];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self refreshViews];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

}

- (IBAction)pushCodeButton:(UIButton *)sender
{
    sender.enabled = NO;
    self.keyBoardMode = ePOSKeyboardModeIemCode;
}

- (IBAction)pushRemoveItem:(id)sender
{
    if(_itemManager.count != 0) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [_itemManager removeItemAtIndex:indexPath.row];
        [self refreshViews];
        if ( [self.delegate respondsToSelector:@selector(ePOSItemViewControllerDidUpdateItems:)] ) {
            [self.delegate ePOSItemViewControllerDidUpdateItems:self];
        }

        if(_itemManager.count != 0) {
            if(_itemManager.count <= indexPath.row) {
                indexPath = [NSIndexPath indexPathForRow:_itemManager.count - 1 inSection:0];
            }
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (IBAction)pushRemoveAllItems:(id)sender
{
    if(_itemManager.count != 0) {
        IWUIAlertView *alert =
        [[IWUIAlertView alloc] initWithTitle:EPOSLocalizedString(@"Delete all items.", _skinManager.language, nil)
                                     message:EPOSLocalizedString(@"Will that be all right?", _skinManager.language, nil)
                                    delegate:nil
                           cancelButtonTitle:EPOSLocalizedString(@"Cancel", _skinManager.language, nil)
                           otherButtonTitles:EPOSLocalizedString(@"OK", _skinManager.language, nil), nil];
        [alert showWithCompletionHandler:^(NSInteger button){
            if(button == 1) {
                [self removeAllItems];
            }
        }];
    }
}


- (void)addItem
{
    [self refreshViews];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_itemManager.count-1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

- (void)updateQuantity:(BOOL)incrimet
{
    if(_itemManager.count == 0) return;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [_itemManager updateIndex:indexPath.row increment:incrimet];

    [self refreshViews];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (NSInteger)selectedIndex
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    return indexPath.row;
}

- (void)removeAllItems
{
    // Add start 2018/3/1
    _itemCodeValue.text = @"";
    // Add end 2018/3/1
    
    self.keyBoardMode = ePOSKeyboardModeNone;
    [_itemManager removeAllItems];
    [self refreshViews];
    if ( [self.delegate respondsToSelector:@selector(ePOSItemViewControllerDidUpdateItems:)] ) {
        [self.delegate ePOSItemViewControllerDidUpdateItems:self];
    }
}


- (void)pushKeyboard:(NSInteger)number
{
    if(number == ePOSKeyboardKeyKindPeriod) return;
    
    if(number == ePOSKeyboardKeyKindZeroZero) {
        _itemCode = [_itemCode stringByAppendingString:@"00"];
    } else {
        _itemCode = [_itemCode stringByAppendingString:[@(number) stringValue]];
    }
    //_itemCodeValue.text = _itemCode;
    if(_itemCode.length > 13) {
        self.keyBoardMode = ePOSKeyboardModeNormal;
    } else {
        NSString *name = [_dataManager nameFromCode:_itemCode];
        if(name.length) {
            if ( [self.delegate respondsToSelector:@selector(ePOSItemViewController:addItem:)] ) {
                [self.delegate ePOSItemViewController:self addItem:_itemCode];
            }
            self.keyBoardMode = ePOSKeyboardModeNormal;
        }
    }
}

- (void)clearDeposit
{
}

- (void)refreshViews
{
    [self.tableView reloadData];
    _subtotalValue.text = _itemManager.total;
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#define MAX_LINE 14
    return MAX_LINE > _itemManager.count ? MAX_LINE : _itemManager.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];

    if(indexPath.row % 2 == 0) {
        cell.backgroundColor = _skinManager.tableViewBacgroundColor1;
    } else {
        cell.backgroundColor = _skinManager.tableViewBacgroundColor2;
    }
    cell.separatorInset = UIEdgeInsetsZero;
    
    UILabel *itemLabel = (UILabel *)[cell viewWithTag:10];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:11];
    UILabel *qtyLabel = (UILabel *)[cell viewWithTag:12];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:13];

    if(_itemManager.count > indexPath.row) {
        
        itemLabel.text = [_itemManager nameAtIndex:indexPath.row];
        priceLabel.text = [_itemManager priceAtIndex:indexPath.row];
        qtyLabel.text = [@([_itemManager quantityAtIndex:indexPath.row]) stringValue];
        amountLabel.text = [_itemManager amountAtIndex:indexPath.row];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor orangeColor];
        cell.selectedBackgroundView = bgView;
    } else {
        itemLabel.text = @"";
        priceLabel.text = @"";
        qtyLabel.text = @"";
        amountLabel.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row > _itemManager.count) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_itemManager removeItemAtIndex:indexPath.row];
        [self refreshViews];
        if ( [self.delegate respondsToSelector:@selector(ePOSItemViewControllerDidUpdateItems:)] ) {
            [self.delegate ePOSItemViewControllerDidUpdateItems:self];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EPOSLocalizedString(@"Delete", _skinManager.language, nil);
}

//
- (void)setKeyBoardMode:(ePOSKeyboardMode)keyBoardMode
{
    if(keyBoardMode == ePOSKeyboardModeIemCode) {
        _codeButton.backgroundColor = _skinManager.hilightColor;
        _itemRemoveButton.enabled = NO;
        _itemAllRemoveButton.enabled = NO;
        if ( [self.delegate respondsToSelector:@selector(ePOSItemViewController:didSelectItemCode:)] ) {
            [self.delegate ePOSItemViewController:self didSelectItemCode:YES];
        }
    } else if(keyBoardMode == ePOSKeyboardModeNormal) {
        _codeButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        _codeButton.enabled = YES;
        _itemRemoveButton.enabled = YES;
        _itemAllRemoveButton.enabled = YES;

        _itemCode = @"";
        //_itemCodeValue.text = _itemCode;
        if ( [self.delegate respondsToSelector:@selector(ePOSItemViewController:didSelectItemCode:)] ) {
            [self.delegate ePOSItemViewController:self didSelectItemCode:NO];
        }
    } else if(keyBoardMode == ePOSKeyboardModeDeposit) {
        _itemRemoveButton.enabled = NO;
        _itemAllRemoveButton.enabled = NO;
        _codeButton.enabled = NO;
    } else if(keyBoardMode == ePOSKeyboardModeNone) {
        _itemRemoveButton.enabled = NO;
        _itemAllRemoveButton.enabled = NO;
        _codeButton.enabled = YES;
    }

}
- (void)clearItemCode
{
    if(_itemCode.length != 0) {
        _itemCode = @"";
        //_itemCodeValue.text = _itemCode;
    } else {
        self.keyBoardMode = ePOSKeyboardModeNormal;
    }
}

- (void)setMemberID:(NSString*) scanData{
    _itemCodeValue.text = scanData;
}

- (NSString* )getMemberID{
    return _itemCodeValue.text;
}
@end
