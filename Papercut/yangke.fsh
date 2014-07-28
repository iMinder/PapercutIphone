precision lowp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

float res = textureCoordinate.x;
float n0 = 97.0 / res;
float n1 = 15.0 / res;
float n2 = 97.0 / res;
float n3 = 9.7 / res;
float total = n2 + ( 4.0 * n0 ) + ( 4.0 * n1 );
const vec3 div3 = vec3(1.0 / 3.0);

void main()
{
    float offset, temp1, temp2;
    
    vec4 m, p0, p1, p2, p3, p4, p5, p6, p7, p8;
    
    offset = n3;
    
    p0=texture2D(inputImageTexture,textureCoordinate);
    
    p1=texture2D(inputImageTexture,textureCoordinate+vec2(-offset,-offset));
    
    p2=texture2D(inputImageTexture,textureCoordinate+vec2( offset,-offset));
    
    p3=texture2D(inputImageTexture,textureCoordinate+vec2( offset, offset));
    
    p4=texture2D(inputImageTexture,textureCoordinate+vec2(-offset, offset));
    
    offset = n3*2.0;
    
    p5=texture2D(inputImageTexture,textureCoordinate+vec2(-offset,-offset));
    
    p6=texture2D(inputImageTexture,textureCoordinate+vec2( offset,-offset));
    
    p7=texture2D(inputImageTexture,textureCoordinate+vec2( offset, offset));
    
    p8=texture2D(inputImageTexture,textureCoordinate+vec2(-offset, offset));
    
    m = (p0 * n2 + (p1 + p2 + p3 + p4) * n0 + (p5 + p6 + p7 + p8) * n1) / total;
    
    //convert to b/w
    
    temp1 = dot(p0.rgb, div3);
    
    temp2 = dot(m.rgb, div3);
    
    //color dodge blend mode
    if (temp2 <= 0.0005)
    {
        gl_FragColor = vec4( 1.0, 1.0, 1.0, p0.a);
        
    }
    else
    {
        gl_FragColor = vec4( vec3(min(temp1 / temp2, 1.0)), p0.a);
    }
}