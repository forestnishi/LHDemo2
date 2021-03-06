//
//  ePOSDataSettingsProductTableViewController.m
//  ePOS
//
//  Created by komatsu on 2014/07/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSDataSettingsProductTableViewController.h"
#import "ePOSDataManager.h"
#import "ePOSSkinManager.h"

@interface ePOSDataSettingsProductTableViewController ()

@end

@implementation ePOSDataSettingsProductTableViewController
{
    ePOSSkinManager *_skinManager;
    NSArray *_keys;
    NSMutableDictionary *_productsDictionary;
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
    
    [self setupKeys];
    
    _skinManager = [ePOSSkinManager sharedSkinManager];
    
    _settinsItemController.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_settinsItemController addButtonEnable:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_settinsItemController disable];
    [_settinsItemController addButtonEnable:NO];
}

- (void)setupKeys
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:_productsDictionary.allKeys];
    
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    _keys = [NSArray arrayWithArray:array];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProducts:(NSDictionary *)products
{
    _productsDictionary = nil;
    if(products) {
        _productsDictionary = [NSMutableDictionary dictionaryWithDictionary:products];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _keys.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    
    NSString *keyString = _keys[indexPath.row];
    
    NSDictionary *dict = _productsDictionary[keyString];
    NSString *name = nil;
    if(_skinManager.language == ePOSLanguageJapanese ) {
        name = dict[ePOSDataNameJapaneseKey];
    } else {
        name = dict[ePOSDataNameEnglishKey];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", keyString, name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *keyString = _keys[indexPath.row];
    
    [_settinsItemController setProductKey:_keys[indexPath.row] dictionary:_productsDictionary[keyString]];
}

#pragma mark - delegate
- (void)dataSettingsItemViewController:(ePOSDataSettingsItemViewController *)dataSettingsItemViewController didChangeProduct:(NSDictionary *)product forKey:(NSString *)key;
{
    _productsDictionary[key] = product;
    [self setupKeys];
    [self.tableView reloadData];
    
    if ( [self.delegate respondsToSelector:@selector(dataSettingsProductTableViewController:didChangeProduct:)] ) {
        [self.delegate dataSettingsProductTableViewController:self didChangeProduct:_productsDictionary];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_productsDictionary removeObjectForKey:_keys[indexPath.row]];
        [self setupKeys];
        [_settinsItemController disable];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ( [self.delegate respondsToSelector:@selector(dataSettingsProductTableViewController:didChangeProduct:)] ) {
            [self.delegate dataSettingsProductTableViewController:self didChangeProduct:_productsDictionary];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
