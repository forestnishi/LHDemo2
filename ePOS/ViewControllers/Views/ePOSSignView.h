//
//  ePOSSignView.h
//  ePOS
//
//  Created by komatsu on 2014/06/18.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ePOSSignView : UIView

@property (nonatomic, strong) NSMutableArray *contentDicts;

- (void)clearSign;

@end
