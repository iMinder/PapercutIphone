//
//  ToolCell.m
//  Papercut
//
//  Created by jackie on 15/1/23.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "ToolCell.h"

@implementation ToolCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
//    self.tool = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
//    self.tool.transform = CGAffineTransformRotate(self.tool.transform, M_PI_2);
//    [self.contentView addSubview:self.tool];
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_2);
    
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}
@end
