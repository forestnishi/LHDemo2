//
//  ePOSSplitViewController.m
//  ePOS
//
//  Created by komatsu on 2014/06/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSSplitViewController.h"
#import "ePOSDataSettingsManager.h"
#import "ePOSDataSettingsItemViewController.h"
#import "ePOSDataSettingsTableViewController.h"

@interface ePOSSplitViewController ()

@end

@implementation ePOSSplitViewController
{
    ePOSDataSettingsManager *_dataSettingsManager;
    ePOSDataSettingsItemViewController *_itemViewController;
    ePOSDataSettingsTableViewController *_tableViewContrller;
}

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

    _dataSettingsManager = [[ePOSDataSettingsManager alloc] init];
    
    NSArray *controllers = self.viewControllers;
    UINavigationController *navi1 = controllers[0];
    _tableViewContrller = (ePOSDataSettingsTableViewController *)navi1.topViewController;
    _tableViewContrller.dataSettingsManager = _dataSettingsManager;
    UINavigationController *navi2 = controllers[1];
    _itemViewController = (ePOSDataSettingsItemViewController *)navi2.topViewController;
    _itemViewController.dataSettingsManager = _dataSettingsManager;

    
    _tableViewContrller.settinsItemController = _itemViewController;
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = self.view.superview.bounds;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeViewController
{
    [CATransaction begin];
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromRight;
    transition.duration = 0.3;
    transition.fillMode = kCAFillModeRemoved;
    transition.removedOnCompletion = YES;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:@"transition"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [CATransaction setCompletionBlock: ^ {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(transition.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    }];
    
    [self.view removeFromSuperview];
    
    [CATransaction commit];

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

@end
