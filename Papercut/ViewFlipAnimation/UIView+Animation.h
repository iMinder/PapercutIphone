//
//  UIView+Animation.h
//  Papercut
//
//  Created by jackie on 15/5/7.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, AnimationType)
{
    ATVertically, // -
    ATHorizonally ,// |
    ATRightBottomFoldAnimation, // _|
    ATRightTopFoldAnimation, // |-
};

@interface UIView (Animation)

- (void)animationWithType:(AnimationType)type;

@end
