//
//  PaperCutLearnCell.h
//  Papercut
//
//  Created by jackie on 15/1/30.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LearnModel;
@protocol LearnModel;

typedef void(^SelectBlock)(LearnModel *item);

@interface PaperCutLearnCell :UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource>


@property (nonatomic, strong) NSArray<LearnModel> *items;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, copy) SelectBlock selectBlock;

@end

