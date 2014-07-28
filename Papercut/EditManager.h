//
//  EditManager.h
//  Papercut
//
//  Created by jackie on 14-7-25.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditManager : NSObject

- (UIImage *)undoWithImage:(UIImage *)lastImage;
- (UIImage *)redoWithImage:(UIImage *)image;
- (void)addUndoImage:(UIImage *)undoImage;

@end
