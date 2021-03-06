//
//  ePOSDataSettingsItemViewController.m
//  ePOS
//
//  Created by komatsu on 2014/06/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSDataSettingsItemViewController.h"
#import "ePOSSplitViewController.h"
#import "ePOSDataSettingsManager.h"
#import "ePOSDataManager.h"
#import "IWUIAlertView.h"
#import "ePOSSkinManager.h"

@interface ePOSDataSettingsItemViewController ()
{
    ePOSSplitViewController *_splitViewController;
    ePOSDataSettingsManager *_dataSettingsManager;
    NSMutableDictionary *_product;
    UITextField *_textField;
}
@end

@implementation ePOSDataSettingsItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _splitViewController = (ePOSSplitViewController *)self.splitViewController;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    void (^process)() = ^(NSNotification *notification) {
        _textField = notification.object;
        if([self checkField]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidBeginEditingNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        process(notification);
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        process(notification);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushDone:(id)sender
{
    [_textField resignFirstResponder];
    
    if([self checkField]) {
        if(_product == nil) {
            _product = [NSMutableDictionary dictionary];
        }
        _product[ePOSDataNameEnglishKey] = _nameEnglish.text;
        _product[ePOSDataNameJapaneseKey] = _nameJapanese.text;
        _product[ePOSDataNamePhoneticEnglishKey] = _displayNameEnglish.text;
        _product[ePOSDataNamePhoneticJapanesehKey] = _displayNameJapanese.text;
        _product[ePOSDataPriceKey] = _price.text;
        if(_imageName.text.length) {
            _product[ePOSDataProductImageKey] = _imageName.text;
        }

        if ( [self.delegate respondsToSelector:@selector(dataSettingsItemViewController:didChangeProduct:forKey:)] ) {
            [self.delegate dataSettingsItemViewController:self didChangeProduct:_product forKey:_productCode.text];
        }
        self.navigationItem.leftBarButtonItem.enabled = YES;
    } else {
        ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];

        IWUIAlertView *alert =
        [[IWUIAlertView alloc] initWithTitle:EPOSLocalizedString(@"Please enter the correct data.", skinManager.language, nil)
                                     message:nil
                                    delegate:nil
                           cancelButtonTitle:EPOSLocalizedString(@"OK", skinManager.language, nil)
                           otherButtonTitles:nil, nil];
        [alert showWithCompletionHandler:^(NSInteger button){
        }];
    }
}

- (IBAction)pushAdd:(id)sender
{
    _product = [NSMutableDictionary dictionary];
    [self disable];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (BOOL)checkField
{
    if(_productCode.text.length &&
       _nameEnglish.text.length &&
       _nameJapanese.text.length &&
       _displayNameEnglish.text.length &&
       _displayNameJapanese.text.length &&
       _price.text.length) {

        return YES;
    }
    return NO;
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

- (void)closeView
{
    [_splitViewController closeViewController];
}

- (void)disable
{
    _productCode.text = @"";
    _nameEnglish.text = @"";
    _nameJapanese.text = @"";
    _displayNameEnglish.text = @"";
    _displayNameJapanese.text = @"";
    _price.text = @"";
    _imageName.text = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)addButtonEnable:(BOOL)enable
{
    self.navigationItem.leftBarButtonItem.enabled = enable;
}

- (void)setProductKey:(NSString *)key dictionary:(NSDictionary *)product
{
    if(product) {
        _product = [NSMutableDictionary dictionaryWithDictionary:product];
        _productCode.text = key;
        _nameEnglish.text = product[ePOSDataNameEnglishKey];
        _nameJapanese.text = product[ePOSDataNameJapaneseKey];
        _displayNameEnglish.text = product[ePOSDataNamePhoneticEnglishKey];
        _displayNameJapanese.text = product[ePOSDataNamePhoneticJapanesehKey];
        _price.text = product[ePOSDataPriceKey];
        _imageName.text = product[ePOSDataProductImageKey];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        _product = [NSMutableDictionary dictionary];
    }
}

@end
