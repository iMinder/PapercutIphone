//
//  UIView+Animation.m
//  Papercut
//
//  Created by jackie on 15/5/7.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "UIView+Animation.h"
#import <objc/runtime.h>

#define POINT(x,y) CGPointMake(x,y)

static const NSString *kTypeValue = @"kTypeValue";
static const NSString *kOverlayView = @"overlay";

@implementation UIView (Animation)

- (UIView *)overlayView
{
    UIView  *overlay = [self snapshotViewAfterScreenUpdates:NO];
    return overlay;
}

- (void)setOverlay: (UIView *)view
{
    objc_setAssociatedObject(self, (__bridge const void *)(kOverlayView), view, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)overlay
{
    return (UIView *) objc_getAssociatedObject(self, (__bridge const void *)(kOverlayView));
}

- (UIBezierPath *)pathForType:(AnimationType)type isStatic:(BOOL)isStatic
{
    CGFloat height =  CGRectGetHeight(self.frame);
    CGFloat width  =  CGRectGetWidth(self.frame);
    
    UIBezierPath *path = [UIBezierPath new];
    switch (type)
    {
        case ATVertically:
        { //垂直翻转的裁剪
            
            [path moveToPoint:POINT(0, 0)];
            [path addLineToPoint:POINT(width, 0)];
            [path addLineToPoint:POINT(width, height / 2)];
            [path addLineToPoint:POINT(0, height /2)];
            [path closePath];
            if (!isStatic)
            {
                [path applyTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, height / 2)];
            }
            
        }
            break;
        case ATHorizonally:
        {
            [path moveToPoint:(CGPoint){0,0}];
            [path addLineToPoint:POINT(width / 2, 0)];
            [path addLineToPoint:POINT(width / 2, height)];
            [path addLineToPoint:POINT(0, height)];
            [path closePath];
            if (!isStatic) {
                [path applyTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, width / 2, 0)];
            }
            
        }
            break;
        case ATRightBottomFoldAnimation:
        {
            [path moveToPoint:POINT(0, 0)];
            [path addLineToPoint:POINT(width, height)];
            [path addLineToPoint:isStatic ? POINT(0, height):POINT(width, 0)];
            [path closePath];
            
        }
            break;
        case ATRightTopFoldAnimation:
        {
            [path moveToPoint:POINT(width, 0)];
            [path addLineToPoint:POINT(0, height)];
            [path addLineToPoint:isStatic ? POINT(0, 0) : POINT(width, height)];
            [path closePath];
        }
            break;
        default:
            assert("NO directon defined");
            break;
    }
    return path;
}

- (void)addMaskForView:(UIView *)view isStatic:(BOOL)isStatic withTpye:(AnimationType)type
{
    CAShapeLayer *masks = (CAShapeLayer *)view.layer.mask;
    if (masks == nil) {
        masks = [CAShapeLayer layer];
    }
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = self.layer.bounds;
    [mask setPath:[self pathForType:type isStatic:isStatic].CGPath];
    [masks addSublayer:mask];
    view.layer.mask = masks;
}

- (void)animationWithType:(AnimationType)type
{
    //增加一个animation 动画
    if ([self.layer.animationKeys count] > 0) {
        return;
    }
    
    UIView *overlay = [[UIView alloc] initWithFrame:self.frame];
    [self setOverlay:overlay];
    [self.superview insertSubview:overlay aboveSubview:self];
    
    UIView *staticView = [self overlayView];
    [self addMaskForView:staticView isStatic:YES withTpye:type];
    [self addMaskForView:self isStatic:NO withTpye:type];
    [overlay addSubview:staticView];
//
//    //rotate view
//    UIView *rotateView = [self overlayView];
//    [self addMaskForView:rotateView isStatic:NO withTpye:type];
//    [overlay addSubview:rotateView];
  
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1 / -2000;
    animation.duration =  1.0;
    animation.delegate = self;
    animation.autoreverses = NO;
    self.layer.zPosition = 2000.0f;
    NSArray *values;
    switch (type) {
        case ATVertically:
            values = @[[NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * M_PI / 2, 1, 0, 0)],
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, 1, 0, 0)],
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 2 * M_PI / 2, 1, 0, 0)]
                       ];
            break;
        case ATHorizonally:
            values = @[[NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * M_PI / 2, 0, 1, 0)],
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, 0, 1, 0)],
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 2 * M_PI / 2, 0, 1, 0)]
                       ];
            break;
        case ATRightTopFoldAnimation:
            values = @[[NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * M_PI / 2, -1, 1, 0)],
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, -1, 1, 0)],
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 2 * M_PI / 2, -1, 1, 0)]
                       ];
            break;

        case ATRightBottomFoldAnimation:
            values = @[
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * M_PI / 2, 1, 1, 0)],
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, 1, 1, 0)],
                       [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 2 * M_PI / 2, 1, 1, 0)]
                       ];
            break;
        default:
            break;
    }
    
    //_canvas.layer.transform = transform;
    animation.values = values;
 
    [self.layer addAnimation:animation forKey:@"rotateCavans"];
    
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
    //开启事务
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
   // self.layer.transform = CATransform3DRotate(self.layer.transform, M_PI, 1.0, 1.0, 0.0);
   
    [[self overlay] removeFromSuperview];
    [self.layer removeAllAnimations];

    [CATransaction commit];
    
    //
   // [self.layer setMask:nil];
   
}

@end

