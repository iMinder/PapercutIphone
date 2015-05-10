//
//  PapercutCanvas.h
//  Papercut
//
//  Created by jackie on 15/3/6.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PapercutCanvas : UIView<UIGestureRecognizerDelegate>

@property BOOL hitTestUsingPath;
@property (copy) UIBezierPath *path;
@property UIColor *fillColor;
@property (copy) NSString *fillRule;
@property UIColor *strokeColor;
@property CGFloat strokeStart, strokeEnd;
@property CGFloat lineWidth;
@property CGFloat miterLimit;
@property (copy) NSString *lineCap;
@property (copy) NSString *lineJoin;
@property CGFloat lineDashPhase;
@property (copy) NSArray *lineDashPattern;

@end
