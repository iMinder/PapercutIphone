//
//  LearnPaperPopViewController.h
//  Papercut
//
//  Created by jackie on 15/2/16.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LearnModel;

@interface LearnPaperPopViewController : UIViewController
{
    NSMutableArray *items;
}
@property (nonatomic, strong) LearnModel *learnItem;
@property (assign) NSInteger index;
@property (nonatomic, strong) NSString *name;

@end
