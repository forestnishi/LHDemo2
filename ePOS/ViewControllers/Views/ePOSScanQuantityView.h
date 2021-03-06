//
//  ePOSScanQuantityView.h
//  ePOS
//
//  Created by komatsu on 2014/06/25.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ePOSScanQuantityView : UIView

@property (nonatomic, weak) IBOutlet UILabel *quantityLabel;
@property (nonatomic, weak) IBOutlet UILabel *quantityTitleLabel;

@property (nonatomic) NSInteger quantity;

@end
