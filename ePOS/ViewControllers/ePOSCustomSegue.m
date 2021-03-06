//
//  ePOSCustomSegue.m
//  ePOS
//
//  Created by komatsu on 2014/06/19.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSCustomSegue.h"

@implementation ePOSCustomSegue

- (void)perform
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
    UIViewController *sourceVC = self.sourceViewController;
    UIViewController *destVC = self.destinationViewController;
    if(sourceVC.navigationController) {
        [sourceVC.navigationController.view addSubview:destVC.view];
    } else {
        [sourceVC.view addSubview:destVC.view];

    }
    
    [CATransaction commit];
}

@end
