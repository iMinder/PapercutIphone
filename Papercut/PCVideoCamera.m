
//
//  PCVideoCamera.m
//  Papercut
//
//  Created by jackie on 14-5-28.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "PCVideoCamera.h"

@interface PCVideoCamera()

@property (strong, nonatomic) GPUImageGaussianBlurFilter *gaussianBlurFilter;
@property (strong, nonatomic) GPUImageGrayscaleFilter *grayFilter;
@property (strong, nonatomic) GPUImageColorDodgeBlendFilter *colorDodgeFilter;
@property (strong, nonatomic) GPUImageColorInvertFilter *colorInvertFilter;
@property (strong, nonatomic) GPUImageFilter *normalFilter;
@property (strong, nonatomic) GPUImageFilter *internalFilter;
@property (strong, nonatomic) GPUImageFilter *lineFirstFilter;
@property (strong, nonatomic) GPUImageFilter *lineLastFilter;

@property (strong, nonatomic, readwrite) GPUImageView *gpuImageView;
@property (strong, nonatomic, readwrite) GPUImageView *gpuImageView_HD;
@property (strong, nonatomic) GPUImagePicture *stillImageSource;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) dispatch_queue_t prepareFilterQueue;
@property (strong, nonatomic) AVMutableComposition *mutableComposition;
@property (strong, nonatomic) AVAssetExportSession *assetExportSession;

- (void)forceSwitchToNewFilter:(PCFilterType)newFilterType;

@end

@implementation PCVideoCamera

//- (GPUImageGaussianBlurFilter *)gaussianBlurFilter
//{
//    if (_gaussianBlurFilter == nil)
//    {
//        self.gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc]init];
//    }
//    return _gaussianBlurFilter;
//}
//
//- (GPUImageGrayscaleFilter *)grayFilter
//{
//    if (_grayFilter == nil)
//    {
//        _grayFilter = [[GPUImageGrayscaleFilter alloc]init];
//    }
//    return _grayFilter;
//}
//
//- (GPUImageColorInvertFilter *)colorInvertFilter
//{
//    if (_colorInvertFilter == nil)
//    {
//        _colorInvertFilter = [[GPUImageColorInvertFilter alloc]init];
//    }
//    return _colorInvertFilter;
//}
//
//- (GPUImageColorDodgeBlendFilter *)colorDodgeFilter
//{
//    if (_colorDodgeFilter)
//    {
//        _colorDodgeFilter = [[GPUImageColorDodgeBlendFilter alloc]init];
//    }
//    return _colorDodgeFilter;
//}
//
//- (GPUImageFilter *)normalFilter
//{
//    if (_normalFilter == nil)
//    {
//        _normalFilter = [[GPUImageFilter alloc]init];
//    }
//    return _normalFilter;
//}

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition highImageQuality:(BOOL)isHighQuality
{
    self = [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition];
    if (self == nil)
    {
        return  nil;
    }
    
    self.prepareFilterQueue  = dispatch_queue_create("com.papercut.prepareFilterQueue", NULL);
    
    //设置默认滤镜无

    self.normalFilter = [[GPUImageFilter alloc]init];
    self.grayFilter = [[GPUImageGrayscaleFilter alloc]init];
    self.colorInvertFilter = [[GPUImageColorInvertFilter alloc]init];
    self.gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc]init];
    
    //gray -> colorInvert -> gaussian
    [self.grayFilter addTarget:self.colorInvertFilter];
    [self.colorInvertFilter addTarget:self.gaussianBlurFilter];
    
    self.lineFirstFilter = nil;
    self.lineLastFilter = self.normalFilter;
    _currentFilterType = PC_NORMAL_FILTER;
    
    //设置view
    self.gpuImageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
    if (isHighQuality)
    {
        _gpuImageView.layer.contentsScale = 2.0;
        _gpuImageView_HD.layer.contentsScale = 2.0;
    }
    else
    {
        _gpuImageView.layer.contentsScale = 1.0;
        _gpuImageView_HD.layer.contentsScale = 1.0;
        
    }
    
    [self addTarget:_normalFilter];
    [self.normalFilter  addTarget:_gpuImageView];
    
    //用于输出，当拍照时，用gpuImageView_HD显示结果
    self.gpuImageView_HD = [[GPUImageView alloc]initWithFrame:self.gpuImageView.bounds];
    self.gpuImageView_HD.hidden = YES;
    [self.gpuImageView addSubview:self.gpuImageView_HD];
    
    return self;
}

- (void)swithFilter:(PCFilterType)normalFilterType
{
    //如果是从相册选取的一张照片，就对照片进行滤镜处理
    if (self.rawImage != nil && self.stillImageSource == nil)
    {
        self.stillImageSource = [[GPUImagePicture alloc]initWithImage:self.rawImage];
  
    }
    else
    {
        //如果当前滤镜效果和filtrType相同，就不变
        if (self.currentFilterType == normalFilterType)
        {
            return;
        }
    }
    
    [self forceSwitchToNewFilter:normalFilterType];
}

- (void)forceSwitchToNewFilter:(PCFilterType)newFilterType
{
    _currentFilterType = newFilterType;
    
    dispatch_async(_prepareFilterQueue, ^{
        switch (newFilterType)
        {
            case PC_NORMAL_FILTER:
            {
                //无处理效果
                self.lineFirstFilter = nil;
                self.lineLastFilter = self.normalFilter;
                break;
            }
            case PC_YANGKE_FILTER:
            {
                //阳刻效果
               
                self.lineFirstFilter = self.grayFilter;
                //在使用之前，移除之后的所有目标
                [self.gaussianBlurFilter removeAllTargets];
                self.lineLastFilter = self.gaussianBlurFilter;
                break;
            }

            case PC_YINKE_FILTER:
            {
                //阴刻效果
                
                break;
            }
               
            case PC_SIDEFACE_FILTER:
            {
                break;
            }
            default:
                break;
        }
        //切换到真正的normalFilter
        [self performSelectorOnMainThread:@selector(swithToNewFilter) withObject:nil waitUntilDone:NO];
        
    });
}

//切换到相应的滤镜
- (void)swithToNewFilter
{
    [self.normalFilter removeAllTargets];

    if (self.lineFirstFilter != nil)
    {
        [self.normalFilter addTarget:self.lineFirstFilter];
    }
   
    [self removeAllTargets];
    [self.stillImageSource removeAllTargets];
    
    //静态图片显示
    if (self.stillImageSource != nil)
    {
        //切换为新滤镜,照片处理后显示到gpuImageView_HD上
        [self.stillImageSource addTarget:self.normalFilter];
        self.gpuImageView_HD.hidden = NO;
        [self.lineLastFilter addTarget:_gpuImageView_HD];
        [_stillImageSource processImage];
    }
    else
    {
        //切换到新滤镜，然后显示实时滤镜效果
        [self addTarget:self.normalFilter];
        [self.lineLastFilter addTarget:_gpuImageView];
    }
}

/**
 * 拍摄照片
 */
- (void)takePhoto
{
    if ([self.delegate respondsToSelector:@selector(PCVideCameraWillStartCaptureStillImage:)])
    {
        [self.delegate PCVideCameraWillStartCaptureStillImage:self];
    }
    //开始拍照
    [self capturePhotoAsImageProcessedUpToFilter:(GPUImageOutput<GPUImageInput> *) _normalFilter
                                 withOrientation:0
                           withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                               
                               self.rawImage = processedImage;
                               //调用一次，实际是为了显示照片到gpuImageView_HD上
                               [self swithFilter:_currentFilterType];
                               
                               if ([self.delegate respondsToSelector:@selector(PCVideCameraDidFinishCaptureStillImage:)])
                               {
                                   [self.delegate PCVideCameraDidFinishCaptureStillImage:self];
                               }
                           }];
    
}

/**
 * 取消选中的图片
 */
- (void)cancelAlbumPhotoAndGoBackToNormal
{
    self.stillImageSource = nil;
    self.rawImage = nil;
    self.gpuImageView_HD.hidden = YES;
    
    //一定要强制切换下
    [self forceSwitchToNewFilter:_currentFilterType];
    [self startCameraCapture];
}

/**
 * 保存图片
 */
- (void)saveCurrentStillImage
{
    
}
@end
