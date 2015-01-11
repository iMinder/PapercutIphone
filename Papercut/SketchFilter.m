//
//  SketchFilter.m
//  Papercut
//
//  Created by jackie on 15/1/11.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "SketchFilter.h"


@implementation SketchFilter

- (id)init
{
    if (!(self = [super initWithFragmentShaderFromFile:@"sketchfilter"])) {
        return nil;
    }
    return self;
}
@end
