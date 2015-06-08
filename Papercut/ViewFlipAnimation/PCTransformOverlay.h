//
//  PCTransformOverlay.h
//  Papercut
//
//  Created by jackie on 15/5/27.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PapercutCanvas;

@interface PCTransformOverlay : UIControl<UIGestureRecognizerDelegate> {
    CGAffineTransform   transform_;
    float               initialScale_;
    float               initialAngle_;
    UIToolbar           *toolbar_;
    UINavigationBar     *navbar_;
}

@property (nonatomic, weak) PapercutCanvas *canvas;
@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, copy) void (^acceptBlock)(void);
@property (nonatomic, readonly) CGAffineTransform alignedTransform;
@property (nonatomic) BOOL horizontalFlip;
@property (nonatomic) BOOL verticalFlip;
@property (nonatomic) NSString *prompt;
@property (nonatomic) NSString *title;
@property (nonatomic) BOOL showToolbar;

- (CGAffineTransform) configureInitialPhotoTransform;

@end
