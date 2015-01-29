//
//  ShowCameraViewController.h
//  Papercut
//
//  Created by jackie on 14-5-26.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

typedef enum{
    kPapercutNormalFilter,
    kPapercutYangKeFilter,
    kPapercutYinKeFilter,
} PapercutFilterType;

@interface ShowCameraViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@interface UIImage(RedBoarder)

- (UIImage *)imageWithRedBorder;

@end