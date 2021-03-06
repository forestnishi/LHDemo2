//
//  ePOSViewController.h
//  ePOS
//
//  Created by komatsu on 2014/06/13.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "ePOSToolbarViewController.h"
#import "ePOSKeyboardViewController.h"
#import "ePOSItemViewController.h"

@interface ePOSViewController : UIViewController
<
AVCaptureMetadataOutputObjectsDelegate,
ePOSToolbarViewControllerDelegate,
ePOSKeyboardViewControllerDelegate,
ePOSItemViewControllerDelegate
>

@property (nonatomic, weak) IBOutlet UIView *skinSelectView;
@property (nonatomic, weak) IBOutlet UIView *itemView;

@property (nonatomic, readonly) ePOSConnectStatus connectStatus;

- (IBAction)returnActionForSegue:(UIStoryboardSegue *)segue;

- (IBAction)pushBlackSkin:(id)sender;
- (IBAction)pushPinkSkin:(id)sender;
- (IBAction)pushYellowSkin:(id)sender;
- (IBAction)pushPurpleSkin:(id)sender;

- (void)connect;
- (void)disconnect;

@end
