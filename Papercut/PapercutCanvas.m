#import "PapercutCanvas.h"
#import "WDColor.h"
#import "WDActiveState.h"
#import "PCTransformOverlay.h"
#import "UIDeviceHardware.h"
#import "WDUtilities.h"
#define POINT(x,y) CGPointMake(x,y)


@implementation PapercutCanvas
{
    CGFloat initialScale_;
    CGAffineTransform photoTransform_;
    CGAffineTransform rawPhotoTransform;
}
@synthesize transformOverlay = transformOverlay_;

- (CGSize) dimensions
{
    return CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.scale = 1.0;
    self.UUID = generateUUID();
    
    [self initView];
    
    return self;
}

//- (void)configureGestures
//{
//    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlerPinchGesture:)];
//    pinchGesture.delegate  = self;
//    [self addGestureRecognizer:pinchGesture];
//}

- (void)initView
{
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [WDActiveState sharedInstance].paintColor.UIColor;
    _currentView = view;
    self.shapeType = STQquare;
    
    [self addSubview:_currentView];
    
}

- (BOOL)PC_canTransformToType:(AnimationType) animationType
{
    switch (_shapeType) {
        case STQquare:              //正方形
            return YES;
        case STRectangle1:          //垂直的长方形
        case STRectangle2:          //水平的长方形
            return animationType == ATHorizonally || animationType == ATVertically;
        case STLeftTopTriangle:     //左上方的三角形
            return animationType == ATRightTopFoldAnimation;
        case STLeftBottomTriangle:  //左下方的三角形
            return animationType == ATRightBottomFoldAnimation;
        case STLeftToRightTriangle:
            return animationType == ATVertically;
        default:
            break;
    }
    return NO;
}

- (ShapeType) shapeTypeForCurrentType:(AnimationType)animationType_
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    switch (_shapeType) {
        case STQquare:
            switch (animationType_) {
                case ATHorizonally:
                    return STRectangle1;
                case ATVertically:
                    return STRectangle2;
                case ATRightBottomFoldAnimation:
                    return STLeftTopTriangle;
                case ATRightTopFoldAnimation:
                    return STLeftBottomTriangle;
                default:
                    break;
            }
            break;
        case STRectangle1:
        {
            switch (animationType_) {
                case ATHorizonally:
                    return STRectangle1;
                case ATVertically:
                    if (height == 2 * width) {
                        return STQquare;
                    }else if (height > 2 * width){
                        return STRectangle1;
                    }else{
                        return STRectangle2;
                    }
                default:
                    break;
            }
        }
            break;
        case STRectangle2:
        {
            switch (animationType_) {
                case ATVertically:
                    return STRectangle2;
                case ATHorizonally:
                    if (width ==  2 * height) {
                        return STQquare;
                    }else if (width > 2 * height) {
                        return STRectangle2;
                    }else {
                        return STRectangle1;
                    }
                default:
                    break;
            }
        }
            break;
        case STLeftBottomTriangle:          //这两类只允许一种类型
            NSAssert(_animationType == ATRightBottomFoldAnimation, @"not support animation");
            return STLeftToRightTriangle;
        case STLeftTopTriangle:
            NSAssert(_animationType == ATRightTopFoldAnimation , @"not support animation");
            return STLeftToRightTriangle;
        case STLeftToRightTriangle:
            NSAssert(_animationType == ATVertically, @"not support animation");
            return STLeftBottomTriangle;
        default:
            break;
    }
    assert("不支持的类型");
    return STQquare;
    
}
- (void)PC_animationWithType:(AnimationType)type 
{
    _animationType = type;
    [CATransaction begin];
    [self addMaskForView:self isStatic:YES withTpye:type];
    [CATransaction setCompletionBlock:^{
        //设置新的canvas
        CGRect portion = self.bounds;
        UIView *currentView = self;
        switch (type) {
            case ATVertically:
                portion = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) / 2);
                break;
            case ATHorizonally:
                portion = CGRectMake(0, 0, CGRectGetWidth(currentView.frame) / 2, CGRectGetHeight(currentView.frame));
                break;
            case ATRightBottomFoldAnimation:
                if (_shapeType == STLeftBottomTriangle) {
                    portion = CGRectMake(0, 0, CGRectGetWidth(currentView.frame) / 2, CGRectGetHeight(currentView.frame));
                }
            break;
            case ATRightTopFoldAnimation:
            if (_shapeType == STLeftTopTriangle) {
                 portion = CGRectMake(0, 0, CGRectGetWidth(currentView.frame) / 2, CGRectGetHeight(currentView.frame));
            }
            break;
            default:
                break;
        }
        
        PapercutCanvas *newCanvas = [PapercutCanvas new];
        newCanvas.UUID = generateUUID();
        
        newCanvas.currentView =  [self resizableSnapshotViewFromRect:portion afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
        newCanvas.backgroundColor = [UIColor clearColor];
        newCanvas.animationType = type;
        newCanvas.shapeType = [self shapeTypeForCurrentType:type];
        newCanvas.bounds = newCanvas.currentView.bounds;
        newCanvas.center = self.center;
        [newCanvas addSubview:newCanvas.currentView];
        if ([self.delegate respondsToSelector:@selector(animationDidStop:)]) {
            [self.delegate animationDidStop:newCanvas];
        }
    }];
    [CATransaction commit];
}

- (UIBezierPath *)pathForType:(AnimationType)type isStatic:(BOOL)isStatic
{
    CGFloat height =  CGRectGetHeight(self.bounds);
    CGFloat width  =  CGRectGetWidth(self.bounds);
    
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
            [path moveToPoint:POINT(width, 0)];
            [path addLineToPoint:POINT(0, height)];
            [path addLineToPoint:isStatic ? POINT(0, 0) : POINT(width, height)];
            [path closePath];
         
            
        }
            break;
        case ATRightTopFoldAnimation:
        {
            [path moveToPoint:POINT(0, 0)];
            [path addLineToPoint:POINT(width, height)];
            [path addLineToPoint:isStatic ? POINT(0, height):POINT(width, 0)];
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
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = self.layer.bounds;
    [mask setPath:[self pathForType:type isStatic:isStatic].CGPath];
    view.layer.mask = mask;
}

- (CATransform3D) transformForType:(AnimationType)type
{
    CATransform3D transform = CATransform3DIdentity;
    
    switch (type) {
        case ATVertically:
            transform = CATransform3DRotate(transform, M_PI, 1.0, 0.0, 0.0);
            break;
        case ATHorizonally:
            transform = CATransform3DRotate(transform, M_PI, 0.0, 1.0, 0.0);
            break;
        case ATRightTopFoldAnimation:
            transform = CATransform3DRotate(transform, M_PI, -1.0, 1.0, 0.0);
            break;
        case ATRightBottomFoldAnimation:
            transform = CATransform3DRotate(transform, M_PI, 1.0, 1.0, 0.0);
            break;
        default:
            break;
    }
    return transform;
}

- (CGPoint) convertPointToDocument:(CGPoint)pt
{
    pt.y = CGRectGetHeight(self.bounds) - pt.y;
    
    CGAffineTransform iTx = CGAffineTransformInvert(CGAffineTransformIdentity);
    CGPoint transformed = CGPointApplyAffineTransform(pt, iTx);
    
    return transformed;
}

@end

@implementation PapercutCanvas (PCPlacePhotoMode)


- (void) photoTransformChanged:(PCTransformOverlay *)sender
{
    rawPhotoTransform = sender.alignedTransform;
    _currentImageView.transform = rawPhotoTransform;
    
 }

- (void) beginPhotoPlacement:(UIImage *)image
{
    
    transformOverlay_ = [[PCTransformOverlay alloc] initWithFrame:self.superview.frame];
    transformOverlay_.userInteractionEnabled = YES;
    [self.superview addSubview:transformOverlay_];
    
    self.photo = image;
    transformOverlay_.alpha = 0.0f; // for fade in
    transformOverlay_.canvas = self;
    
    __unsafe_unretained PapercutCanvas *canvas = self;
    transformOverlay_.cancelBlock = ^{ [canvas cancelPhotoPlacement]; };
    transformOverlay_.acceptBlock = ^{ [canvas placePhoto]; };
    
    [transformOverlay_ addTarget:self action:@selector(photoTransformChanged:)
                forControlEvents:UIControlEventValueChanged];
    
    photoTransform_ = [transformOverlay_ configureInitialPhotoTransform];
    rawPhotoTransform = photoTransform_;
    
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                     animations:^{ transformOverlay_.alpha = 1.0f; }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void) cancelPhotoPlacement
{

   [transformOverlay_ removeFromSuperview];
   transformOverlay_ = nil;
        
    self.photo = nil;

}

- (void) placePhoto
{
    [self cancelPhotoPlacement];
}

@end
