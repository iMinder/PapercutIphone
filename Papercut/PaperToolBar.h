//
//  PaperToolBar.h
//  Papercut
//
//  Created by jackie on 15/1/23.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PaperToolBarDelegate<NSObject>

- (void)paperToolBarItemDidSelected:(NSIndexPath*)indexPath;

@end

@interface PaperToolBar : UIView

@property (nonatomic, strong)NSArray *items;
@property (nonatomic, weak)id<PaperToolBarDelegate>delegate;


+ (PaperToolBar *)bottomPaperBarWithTool:(UIToolbar *)toolBar;

- (void)hideToolBar:(BOOL)animated fromToolBar:(UIToolbar *)tb;
- (void)showToolBar:(BOOL)animated fromToolBar:(UIToolbar *)tb;

@end
