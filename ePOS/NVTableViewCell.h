//
//  NVTableViewCell.h
//  ePOS
//
//  Created by katayama akihiko on 2021/02/13.
//  Copyright © 2021 iWare. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NVTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ImageFilePath;

- (IBAction)selectImageFile:(id)sender;
@end

NS_ASSUME_NONNULL_END
