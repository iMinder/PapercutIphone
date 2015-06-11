//
//  PaintView.h
//  Papercut
//
//  Created by jackie on 15/6/10.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PapercutCanvas.h"


@interface PaintView : UIView
{
    UIBezierPath *bPath;
    BOOL closed;
    
}
@property (nonatomic) ShapeType parentShape;

- (id) initWithCanvas:(PapercutCanvas *)canvas;
@end

extern NSString * const PaintViewCaiJianDoneNotification;