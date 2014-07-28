//
//  YangKeFilter.m
//  Papercut
//
//  Created by jackie on 14-5-31.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "YangKeFilter.h"

NSString *const kPCYangKeFilterString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
 
const highp vec3 W = vec3(0.299, 0.587, 0.114);
 
 void main()
 {
     
     vec4 colorTexture = texture2D(inputImageTexture, textureCoordinate);
     
     float gray = dot(colorTexture.rgb, W);
     
     if (gray < 245.0 / 255.0)
     {
         colorTexture = vec4(1.0, 0, 0, colorTexture.a);
     }
     else
     {
         colorTexture = vec4(1.0, 1.0, 1.0,colorTexture.a);
     }
     gl_FragColor = colorTexture;
 }
 );

@implementation YangKeFilter

- (id)init
{
    if (!(self = [super initWithFragmentShaderFromString:kPCYangKeFilterString])) {
        return nil;
    }
    return self;
}
@end
