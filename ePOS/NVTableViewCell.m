//
//  NVTableViewCell.m
//  ePOS
//
//  Created by katayama akihiko on 2021/02/13.
//  Copyright © 2021 iWare. All rights reserved.
//

#import "NVTableViewCell.h"

@implementation NVTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




- (IBAction)selectImageFile:(id)sender {
    self.ImageFilePath.text = @"maido";
}
@end
