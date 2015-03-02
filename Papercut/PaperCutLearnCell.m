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

@implementation PaperCutLearnCell


- (void)setItems:(NSArray *)newItems
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
    
    NSDictionary *item = self.items[indexPath.row];
    NSURL *imgURL = [NSURL URLWithString:item[@"thumbnail"]];
    [cell.thumbnail sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"yinke"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectBlock) {
        NSDictionary *item = self.items[indexPath.row];
        NSInteger index = [item[@"id"] integerValue];
        NSString *name = item[@"title"];
        self.selectBlock(name,index);
    }
}
@end
