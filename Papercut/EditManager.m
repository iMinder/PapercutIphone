//
//  EditManager.m
//  Papercut
//
//  Created by jackie on 14-7-25.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "EditManager.h"

@interface EditManager()

@property (strong, nonatomic) NSMutableArray *undoArray;
@property (strong, nonatomic) NSMutableArray *redoArray;

@end
@implementation EditManager

- (id)init
{
    if (self = [super init]) {
        self.undoArray = [[NSMutableArray alloc]init];
        self.redoArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (UIImage *)undoWithImage:(UIImage *)lastImage
{
    //已经不能倒退了
    if ([self.undoArray count] == 0) {
        
        return nil;
    }
    
    //将最新的保存在
    [self.redoArray addObject:lastImage];
    UIImage *image = [self.undoArray lastObject];
    [self.undoArray removeLastObject];
    
    return image;

}

- (UIImage *)redoWithImage:(UIImage *)image
{
    if ([self.redoArray count] == 0) {
        return nil;
    }
    
    [self.undoArray addObject:image];
    
    UIImage *reImage = [self.redoArray lastObject];
    [self.redoArray removeLastObject];
    
    return reImage;
}

- (void)addUndoImage:(UIImage *)undoImage
{
    [self.undoArray addObject:undoImage];
    
}

- (void)dealloc
{
    [self.undoArray removeAllObjects];
    [self.redoArray removeAllObjects];
    self.undoArray = nil;
    self.redoArray = nil;
    
}
@end
