//
//  PaperToolBar.m
//  Papercut
//
//  Created by jackie on 15/1/23.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "PaperToolBar.h"
#import "ToolCell.h"
NSString *const CELL_ID = @"MY_CELL";

static const NSUInteger    kPaperDefaultBarHeight = 50;
//static const NSUInteger    kLandsdcapePhoneBarHeight = 32;
//static const float         kBarItemShadowOpacity = 0.9f;
static const NSTimeInterval kPaperAnimatedDuration = 0.3;
static const NSUInteger    kToolItemSize = 30;

@interface PaperToolBar()

@end

@implementation PaperToolBar

+ (PaperToolBar *)bottomPaperBarWithTool:(UIToolbar *)toolBar
{
    CGFloat toolY = toolBar.frame.origin.y;
    PaperToolBar *paperToolbar = [[PaperToolBar alloc]initWithFrame:CGRectMake(0, toolY, SCREEN_WIDTH, kPaperDefaultBarHeight)];

    return paperToolbar;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(kToolItemSize, kToolItemSize);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        flowLayout.minimumLineSpacing = 44;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:flowLayout];
        [self addSubview:_collectionView];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.collectionView registerClass:[ToolCell class] forCellWithReuseIdentifier:CELL_ID];
        self.hidden = YES;
    }
    return self;
}


- (void)hideToolBar:(BOOL)animated fromToolBar:(UIToolbar *)tb
{

    if (!self.hidden)
    {
        tb.userInteractionEnabled = NO;
        self.superview.userInteractionEnabled = NO;
        [UIView animateWithDuration:kPaperAnimatedDuration animations:^{
            self.center = CGPointMake(self.center.x, self.center.y + kPaperDefaultBarHeight);
        } completion:^(BOOL finished) {
            self.hidden = YES;
            tb.userInteractionEnabled = YES;
            self.superview.userInteractionEnabled = YES;
        }];
    }

}

- (void)showToolBar:(BOOL)animated fromToolBar:(UIToolbar *)tb
{
    if (self.hidden)
    {
        tb.userInteractionEnabled = NO;
        self.superview.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:kPaperAnimatedDuration animations:^{
            self.center = CGPointMake(self.center.x, self.center.y - kPaperDefaultBarHeight);
        } completion:^(BOOL finished) {
            tb.userInteractionEnabled = YES;
            self.superview.userInteractionEnabled = YES;
            self.hidden = NO;
        }];
    }
    else
    {
        [self hideToolBar:YES fromToolBar:tb];
    }

}
@end
