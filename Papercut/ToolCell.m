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
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

@end
