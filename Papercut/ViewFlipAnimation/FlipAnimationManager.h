//
//  NPViewCollapser.h
//  VisualExploration
//
//  Created by Nebojsa Petrovic on 4/27/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger{
    FlipAnimationHorizonally,
    FlipAnimationVertically,
    FlipRightBottomFoldAnimation,
    FlipRightTopFoldAnimation
} FlipAnimationType;

typedef void (^CompletionBlock)(BOOL finished, UIView *flipView);

@interface FlipAnimationManager : NSObject

+ (instancetype)sharedInstance;

- (UIView *)view;
- (void)startAnimation:(UIView *)flipView
                  Type:(FlipAnimationType)type
             Descending:(BOOL)descending
            Completion:(CompletionBlock)completion;
- (void)unfold;

@end
