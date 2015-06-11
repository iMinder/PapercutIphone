//
//  PaintView.m
//  Papercut
//
//  Created by jackie on 15/6/10.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "PaintView.h"

NSString *const PaintViewCaiJianDoneNotification = @"com.papercut.paintview.touch.done";

@implementation PaintView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL) canPaintInPoint:(CGPoint )point
{
    switch (_parentShape) {
        case STQquare:
        case STRectangle1:
        case STRectangle2:
            return YES;
            break;
        case STLeftTopTriangle:
            return point.x >=0 && point.y >= 0 && point.x + point.y <= CGRectGetWidth(self.bounds);
            break;
        case STLeftBottomTriangle:
            return point.y >= point.x;
            break;
        case STLeftToRightTriangle:
            return point.y >= point.x && point.x + point.y <= CGRectGetHeight(self.bounds);
            break;
        default:
            break;
    }
    return NO;
}

- (id) initWithCanvas:(PapercutCanvas *)canvas
{
    self = [super initWithFrame:canvas.currentView.bounds];
    if (!self) {
        return  nil;
    }
   
    bPath = [UIBezierPath bezierPath];
    bPath.lineWidth = 2.0;
    _parentShape = canvas.shapeType;
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    closed = NO;
    UITouch *bTouch = [[touches allObjects] objectAtIndex:0];
    CGPoint point = [bTouch locationInView:self];
    if ([self canPaintInPoint:point]) {
       [bPath moveToPoint:[bTouch locationInView:self]];
    }
    
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *mTouch = [[touches allObjects ]objectAtIndex:0];
    CGPoint point = [mTouch locationInView:self];
    if ([self canPaintInPoint:point]) {
        [bPath addLineToPoint:[mTouch locationInView:self]];
        [self setNeedsDisplay];
    }
   
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    closed = YES;
    UITouch *eTouch = [[touches allObjects] objectAtIndex:0];
    NSLog(@"%f", [eTouch locationInView:self].y);
    [bPath closePath];
    [self setNeedsDisplay];
    //广播消息，告知已经裁减完成
    [[NSNotificationCenter defaultCenter] postNotificationName:PaintViewCaiJianDoneNotification object:self];
    
   // [bPath removeAllPoints];
}
- (void)drawRect:(CGRect)rect
{
    [[UIColor whiteColor] setStroke];
    [bPath stroke];
    if (closed) {
        [[UIColor whiteColor ]setFill];
        [bPath fill];
    }
}
@end
