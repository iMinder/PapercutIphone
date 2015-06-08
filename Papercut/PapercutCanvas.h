//
//  PapercutCanvas.h
//  Papercut
//
//  Created by jackie on 15/3/6.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AnimationType)
{
    ATVertically, // -
    ATHorizonally ,// |
    ATRightTopFoldAnimation, // -|
    ATRightBottomFoldAnimation, // _|
};

typedef NS_ENUM(NSInteger, ShapeType)
{
    STQquare,              //正方形
    STRectangle1,          //垂直的长方形
    STRectangle2,          //水平的长方形
    STLeftBottomTriangle,  //左下方的三角形
    STLeftTopTriangle,     //左上方的三角形
    STLeftToRightTriangle, //向右方指向的三角形
};

@class PapercutCanvas;
@class PCTransformOverlay;

@protocol PapercutCanvasAnimationDelegate <NSObject>
@required
- (void)animationDidStart;
- (void)animationDidStop:(PapercutCanvas *)newCanvas;
@end
                          
@interface PapercutCanvas : UIView<UIGestureRecognizerDelegate>
@property (nonatomic) PCTransformOverlay *transformOverlay;
@property (nonatomic) UIImageView *currentImageView;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, assign) AnimationType animationType;
@property (nonatomic, assign) ShapeType shapeType;
@property (nonatomic, weak)   id<PapercutCanvasAnimationDelegate> delegate;
@property (nonatomic) CGSize dimensions;
@property (nonatomic) UIImage *photo;
@property (nonatomic) CGFloat scale;
@property (nonatomic, strong) NSString *UUID;


- (BOOL)PC_canTransformToType:(AnimationType) animationType;
- (void)PC_animationWithType:(AnimationType)type ;

- (CGPoint) convertPointToDocument:(CGPoint)pt;

@end



@interface PapercutCanvas (PCPlacePhotoMode)
- (void) beginPhotoPlacement:(UIImage *)image;
- (void) cancelPhotoPlacement;
- (void) placePhoto;
@end
