//
//  NSString+Drawing.m
//  Papercut
//
//  Created by jackie on 15/1/29.
//  Copyright (c) 2015年 jackie. All rights reserved.
//
#ifndef __IPHONE_7_0

#import "NSString+Drawing.h"

@implementation NSString (Drawing)


- (CGSize)sizeWithAttributes:(NSDictionary *)attrs {
    return [self sizeWithFont:attrs[NSFontAttributeName]];
}

- (void)drawAtPoint:(CGPoint)point withAttributes:(NSDictionary *)attrs {
    [self drawAtPoint:point withFont:attrs[NSFontAttributeName]];
}

- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs {
    NSParagraphStyle *paraStyle = attrs[NSParagraphStyleAttributeName];
    
    [self drawInRect:rect withFont:attrs[NSFontAttributeName]
       lineBreakMode:paraStyle.lineBreakMode
           alignment:paraStyle.alignment];
}

@end

#endif
