//
//  NSString+Drawing.h
//  Papercut
//
//  Created by jackie on 15/1/29.
//  Copyright (c) 2015年 jackie. All rights reserved.
//
#ifndef __IPHONE_7_0
#import <Foundation/Foundation.h>

@interface NSString (Drawing)

- (CGSize)sizeWithAttributes:(NSDictionary *)attrs;
- (void)drawAtPoint:(CGPoint)point withAttributes:(NSDictionary *)attrs;
- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs;

@end
#endif