//
//  PaperCutLearnCell.m
//  Papercut
//
//  Created by jackie on 15/1/30.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "PaperCutLearnCell.h"
#import "LearnCollectionCell.h"
#import "UIImageView+WebCache.h"
#import "PapercutLearn.h"

@implementation PaperCutLearnCell


- (void)setItems:(NSArray<LearnModel> *)newItems
{
    _items = newItems;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LearnCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    
    LearnModel *item =self.items[indexPath.row];
    NSString *urlPath = [NSString stringWithFormat:@"%@%d.png",item.base_url,item.count];
    NSURL *imgURL = [NSURL URLWithString:urlPath];
    [cell.thumbnail sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"yinke"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectBlock) {
       LearnModel *item =self.items[indexPath.row];
        self.selectBlock(item);
    }
}
@end
