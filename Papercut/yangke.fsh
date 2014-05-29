varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

precision mediump float;

void main()
{
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    
//    lowp vec4 outputColor;
//    outputColor.r = (textureColor.r * 0.393) + (textureColor.g * 0.769) + (textureColor.b * 0.189);
//    outputColor.g = (textureColor.r * 0.349) + (textureColor.g * 0.686) + (textureColor.b * 0.168);
//    outputColor.b = (textureColor.r * 0.272) + (textureColor.g * 0.534) + (textureColor.b * 0.131);
    //mediump float y = dot(textureColor.rbg, vec3(0.3, 0.59, 0.11));
    //初始化高斯矩阵
    //转化为灰度图
    ///textureColor.rgb = vec3(textureColor.r * 0.299, textureColor.g * 0.587, textureColor.b * 0.114);
    float gray = dot(textureColor.rgb, vec3(0.299, 0.587, 0.114));
    vec4 outputColor = vec4(gray, gray, gray, 1.0);
    //反色
    vec4 inverseColor = 1.0 - outputColor;
    //高斯模糊
    
//    if (y > 0.5)
//    {
//        textureColor = vec4(1, 0, 0, 1);
//    }
//    else
//    {
//        textureColor = vec4(0, 0, 0, 1);
//    }
	gl_FragColor = inverseColor;
}