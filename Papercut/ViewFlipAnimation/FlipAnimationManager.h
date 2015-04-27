//
//  NPViewCollapser.h
//  VisualExploration
//
//  Created by Nebojsa Petrovic on 4/27/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import <Foundation/Foundation.h>

#define POINT(x,y) CGPointMake(x,y)

typedef enum : NSUInteger{
    FlipAnimationVertically = 0,
    FlipAnimationHorizonally = 1,
    FlipRightBottomFoldAnimation = 2,
    FlipRightTopFoldAnimation = 3,
} FlipAnimationType;

typedef void (^CompletionBlock)(BOOL finished, UIView *flipViewi , CALayer *foldLayer);

@interface FlipAnimationManager : NSObject

+ (instancetype)sharedInstance;

- (UIView *)view;
- (void)startAnimation:(UIView *)flipView
                  Type:(FlipAnimationType)type
             Descending:(BOOL)descending
            Completion:(CompletionBlock)completion;
- (void)unfold;

@end
