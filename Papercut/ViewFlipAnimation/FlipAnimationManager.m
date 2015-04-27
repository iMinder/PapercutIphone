//
//  NPViewCollapser.m
//  VisualExploration
//
//  Created by Nebojsa Petrovic on 4/27/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import "FlipAnimationManager.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kNPViewCollapserOverlayZPosition = 10000.0f;
static const CGFloat kNPViewCollapserMaxFoldAngle = 87.75;
static const CGFloat kNPViewCollapserM34 = -1.0f / 2000.0f;
static const NSTimeInterval kAnimationDuration = 0.4;
static const CGFloat stepSize = 0.01;



@interface FlipAnimationManager ()

@property (nonatomic, strong)NSTimer *timer;
//block copy 属性
@property (nonatomic, copy)CompletionBlock completionBlock;
@property (nonatomic, assign)CGFloat currentProgress;
@property (nonatomic, assign) BOOL descending;
@property (nonatomic, weak) UIView *viewToFlip;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) CALayer *staticLayer;
@property (nonatomic) CALayer *rotateLayer;
@property (nonatomic, assign)FlipAnimationType flipType;

- (void)refreshOverlay;

@end

@implementation FlipAnimationManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static FlipAnimationManager *flipManager = nil;
    dispatch_once(&onceToken, ^{
        flipManager = [[FlipAnimationManager alloc]init];
    });
    return flipManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _currentProgress = 0.0;
        _descending = NO;
    }
    return self;
}

#pragma mark - Timer method
- (BOOL)finished
{
    return _currentProgress >= 1.0;
}

- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
    CALayer *layer = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.rotateLayer]];
    [self.overlayView removeFromSuperview];
    self.staticLayer = nil;
    self.rotateLayer = nil;
    //调用block
    if (self.completionBlock)
    {
        self.completionBlock(YES,self.viewToFlip, layer);
    }
}

//更新加载位置
- (void)timeTick
{
    _currentProgress += stepSize;
    
    if ([self finished])
    {
        
        [self stop];
    }
    CGFloat amount = _descending ? 1.0 - _currentProgress : _currentProgress;
    [self flipByAmount:amount];
}

- (void)startAnimation:(UIView *)flipView Type:(FlipAnimationType)type Descending:(BOOL)descending Completion:(CompletionBlock)completion
{
    self.descending = descending;
    self.completionBlock = completion;
    self.viewToFlip = flipView;
    self.flipType = type;
    _currentProgress = 0.0;
    [self refreshOverlay];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kAnimationDuration  / (1.0 / stepSize)
                                                  target:self
                                                selector:@selector(timeTick)
                                                userInfo:nil repeats:YES];

}


- (UIView *)view
{
    
    if (self.overlayView && !self.overlayView.hidden)
    {
        return self.overlayView;
    }

    return self.viewToFlip;
}

- (void)refreshOverlay
{
    // Remove the overlay if it exists
    if (self.overlayView)
    {
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
        self.rotateLayer = nil;
        self.staticLayer = nil;
    }

    // 创建Container遮罩
    self.overlayView = [[UIView alloc] initWithFrame:self.viewToFlip.frame];
    [self.overlayView setBackgroundColor:[UIColor clearColor]];
    [self.viewToFlip.superview addSubview:self.overlayView];

    UIImage *viewImage = [self viewContextImage];
    //配置静态界面不动部分
    self.staticLayer = [[CALayer alloc]init];
    self.staticLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.staticLayer.zPosition = kNPViewCollapserOverlayZPosition;
    self.staticLayer.frame = self.viewToFlip.bounds;
    self.staticLayer.contents = (id)viewImage.CGImage;
    //添加CAShapeLayer
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = self.staticLayer.bounds;
    [mask setPath:[self pathForType:_flipType isStatic:YES].CGPath];
    self.staticLayer.mask = mask;
    self.staticLayer.actions = @{@"transform" :[NSNull null], @"opacity" : [NSNull null]};
    [self.overlayView.layer addSublayer:self.staticLayer];
   
    //配置旋转部分
    self.rotateLayer = [[CALayer alloc]init];
    self.rotateLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.rotateLayer.shouldRasterize = YES;
    self.rotateLayer.actions = @{@"transform" :[NSNull null], @"opacity" : [NSNull null]};
    self.rotateLayer.zPosition = kNPViewCollapserOverlayZPosition;
    self.rotateLayer.frame = self.viewToFlip.bounds;
    self.rotateLayer.contents = (id)viewImage.CGImage;
    
    CAShapeLayer *mask2 = [CAShapeLayer new];
    mask2.frame = self.rotateLayer.bounds;
    [mask2 setPath:[self pathForType:_flipType isStatic:NO].CGPath];
    mask2.fillColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_fill"]].CGColor;
    
    self.rotateLayer.mask = mask2;
    [self.overlayView.layer addSublayer:self.rotateLayer];
    

}

- (UIImage *)viewContextImage
{
    //CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(self.viewToFlip.frame.size, YES, 0);
    //CGContextRef context = UIGraphicsGetCurrentContext();
  
    UIView *snap = [self.viewToFlip snapshotViewAfterScreenUpdates:YES];
    //获取当前view的快照
//    [self.viewToFlip drawViewHierarchyInRect:self.viewToFlip.bounds afterScreenUpdates:YES];
    [snap drawViewHierarchyInRect:snap.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
    //返回之前对图片进行处理，如果是黑色，变成透明
    
}

- (UIBezierPath *)pathForType:(FlipAnimationType)type isStatic:(BOOL)isStatic
{
    CGFloat height = self.viewToFlip.frame.size.height;
    CGFloat width = self.viewToFlip.frame.size.width;
    UIBezierPath *path = [UIBezierPath new];
    
    switch (type)
    {
        case FlipAnimationVertically:
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
        case FlipAnimationHorizonally:
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
        case FlipRightTopFoldAnimation:
        {
            [path moveToPoint:POINT(0, 0)];
            [path addLineToPoint:POINT(width, height)];
            [path addLineToPoint:isStatic ? POINT(0, height):POINT(width, 0)];
            [path closePath];
            
        }
            break;
        case FlipRightBottomFoldAnimation:
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

- (void)flipByAmount:(double)amount
{
    if (amount <= 0.0f)
    {
        [self stop];
        self.viewToFlip.hidden = NO;
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
        self.staticLayer = nil;
        self.rotateLayer = nil;
        return;
    }

//    if (!self.overlayView)
//    {
//        [self refreshOverlay];
//    }

    self.viewToFlip.hidden = YES;
    self.overlayView.hidden = NO;
    
    CGFloat rotationAngle = 2 * amount * kNPViewCollapserMaxFoldAngle * M_PI / 180.0f;
    CATransform3D foldTransform = CATransform3DIdentity;
    foldTransform.m34 = kNPViewCollapserM34;
    
    switch (_flipType)
    {
        case FlipAnimationVertically:
            foldTransform = CATransform3DRotate(foldTransform, rotationAngle, 1.0f, 0.0f, 0.0f);
            break;
        case FlipAnimationHorizonally:
            foldTransform = CATransform3DRotate(foldTransform, -rotationAngle, 0.0f, 1.0f, 0.0f);
            break;
        case FlipRightTopFoldAnimation:
            foldTransform = CATransform3DRotate(foldTransform, -rotationAngle, 1.0f, 1.0f, 0.0f); //对角线翻转
            break;
       case FlipRightBottomFoldAnimation:
            foldTransform = CATransform3DRotate(foldTransform, rotationAngle, -1.0f, 1.0f, 0.0f);
            break;
    }
    self.rotateLayer.transform = foldTransform;
}

- (void)unfold
{
    if(!self.overlayView)
        return;
    
    _currentProgress = 0.0;
    self.descending = YES;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kAnimationDuration  / (1.0 / stepSize)
                                                  target:self
                                                selector:@selector(timeTick)
                                                userInfo:nil repeats:YES];

}
@end
