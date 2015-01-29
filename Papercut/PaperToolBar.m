//
//  PaperToolBar.m
//  Papercut
//
//  Created by jackie on 15/1/23.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "PaperToolBar.h"
#import "ToolCell.h"

const NSUInteger    kPaperDefaultBarHeight = 50;
const NSUInteger    kLandsdcapePhoneBarHeight = 32;
const float         kBarItemShadowOpacity = 0.9f;
const NSTimeInterval kPaperAnimatedDuration = 0.3;
const NSUInteger    kToolItemSize = 30;

@interface PaperToolBar()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PaperToolBar

+(PaperToolBar *)bottomPaperBarWithTool:(UIToolbar *)toolBar
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
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView registerClass:[ToolCell class] forCellWithReuseIdentifier:@"MY_CELL"];
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

- (void)setItems:(NSArray *)items
{
    if (items == _items) {
        return;
    }
    _items = items;
    [self.collectionView reloadData];
    
}
#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ToolCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    id path = [self.items objectAtIndex:indexPath.row];
    if ([path isKindOfClass:[NSString class]])
    {
        UIImage *image = [UIImage imageNamed:path];
        [cell.imageView setImage:image];
    }
    return cell;
}

#pragma mark UICollectionView DataSource

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.delegate respondsToSelector:@selector(paperToolBarItemDidSelected:)])
    {
        [self.delegate paperToolBarItemDidSelected:indexPath];
    }
    
    NSLog(@"no delegate response to select item");
}
@end
