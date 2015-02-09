//
//  LineLayout.m
//  Papercut
//
//  Created by jackie on 15/1/30.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "LineLayout.h"
#import "UIDeviceHardware.h"




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
        [self setUp];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}
- (void)setUp
{
    self.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.minimumLineSpacing = 10;
    self.minimumInteritemSpacing = 10;
    self.version = [UIDeviceHardware platform];
    self.sectionInset = [self Inset];
}



@end
