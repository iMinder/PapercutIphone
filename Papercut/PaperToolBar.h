//
//  PaperToolBar.h
//  Papercut
//
//  Created by jackie on 15/1/23.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const CELL_ID;
@interface PaperToolBar : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong)NSArray *items;

+ (PaperToolBar *)bottomPaperBarWithTool:(UIToolbar *)toolBar;

- (void)hideToolBar:(BOOL)animated fromToolBar:(UIToolbar *)tb ;
- (void)showToolBar:(BOOL)animated fromToolBar:(UIToolbar *)tb ;

@end
