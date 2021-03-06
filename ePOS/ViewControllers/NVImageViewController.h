//
//  NVImageViewController.h
//  ePOS
//
//  Created by katayama akihiko on 2021/02/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NVImageViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic) int rowcnt;
- (void) dismissview;
@end

 NS_ASSUME_NONNULL_END
