//
//  LineLayout.m
//  Papercut
//
//  Created by jackie on 15/1/30.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "LineLayout.h"
#import "UIDeviceHardware.h"

#define iPhone6 @"iPhone7,2"
#define iPhone6Plus @"iPhone7,1"


#define ITEM_WIDTH 100
#define ITEM_HEIGHT 120
#define EDGE_DISTANCE 10

@interface LineLayout()

@property (nonatomic, strong)NSString *version;

@end
@implementation LineLayout


- (id)init
{
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = 10;
        self.minimumInteritemSpacing = 10;
        self.version = [UIDeviceHardware platform];
    }
    return self;
}

- (UIEdgeInsets)sectionInset
{
    if ([_version isEqualToString:iPhone6])
    {
        //显示两排
        return UIEdgeInsetsMake(30, 30, 30, 30);
    }
    if ([_version isEqualToString:iPhone6Plus]) {
        //显示三排
        return UIEdgeInsetsMake(30, 10, 30, 10);
    }
    //显示两排
    return UIEdgeInsetsMake(30, 30, 30,30);
}

@end
