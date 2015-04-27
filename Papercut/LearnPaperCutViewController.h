//
//  LearnPapercutViewController.h
//  Papercut
//
//  Created by jackie on 15/3/6.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PCOperationModeNone,
    PCOperationModeCreate,
    PCOperationModeFold,
    PCOperationModeCaijian,
    PCOPerationModeDecorate
} PCOperationMode;

@interface LearnPapercutViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>
{
    PCOperationMode currentOperationMode;
}


@end
