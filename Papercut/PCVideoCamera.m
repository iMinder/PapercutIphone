//
//  PCVideoCamera.m
//  Papercut
//
//  Created by jackie on 14-5-28.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "PCVideoCamera.h"

@interface PCVideoCamera()

@property (strong, nonatomic) GPUImageFilter *filter;
@property (strong, nonatomic) GPUImageFilter *internalFilter;

@property (strong, nonatomic, readwrite) GPUImageView *gpuImageView;
@property (strong, nonatomic, readwrite) GPUImageView *gpuImageView_HD;
@property (strong, nonatomic) GPUImagePicture *stillImageSource;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (strong, nonatomic) AVMutableComposition *mutableComposition;
@property (strong, nonatomic) AVAssetExportSession *assetExportSession;

- (void)forceSwitchToNewFilter:(PCFilterType)newFilterType;
@end

@implementation PCVideoCamera

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition highImageQuality:(BOOL)isHighQuality
{
    self = [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition];
    if (self == nil)
    {
        return  nil;
    }
    
    //设置默认滤镜无
    self.filter = [[GPUImageFilter alloc]init];
    self.internalFilter = _filter;
    self.currentFilterType = PC_NORMAL_FILTER;
    
    [self addTarget:_filter];
    //设置view
    self.gpuImageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
    if (isHighQuality)
    {
        _gpuImageView.layer.contentsScale = 2.0;
    }
    else
    {
        _gpuImageView.layer.contentsScale = 1.0;
    }
    [self addTarget:_filter];
    [_filter addTarget:_gpuImageView];
    
    //用于输出，当拍照时，用gpuImageView_HD显示结果
    self.gpuImageView_HD = [[GPUImageView alloc]initWithFrame:self.gpuImageView.bounds];
    self.gpuImageView_HD.hidden = YES;
    [self.gpuImageView addSubview:self.gpuImageView_HD];
    
    return self;
}

- (void)swithFilter:(PCFilterType)filterType
{
    //如果是从相册选取的一张照片，就对照片进行滤镜处理
    if (self.rawImage != nil && self.stillImageSource == nil)
    {
        self.stillImageSource = [[GPUImagePicture alloc]initWithImage:self.rawImage];
        [self.stillImageSource addTarget:self.filter];
    }
    else
    {
        //如果当前滤镜效果和filtrType相同，就不变
        if (self.currentFilterType == filterType)
        {
            return;
        }
    }
    [self forceSwitchToNewFilter:filterType];
}

- (void)forceSwitchToNewFilter:(PCFilterType)newFilterType
{
    _currentFilterType = newFilterType;
    dispatch_queue_t prepareFilterQueue  = dispatch_queue_create("com.papercut.prepareFilterQueue", NULL);
    dispatch_async(prepareFilterQueue, ^{
        switch (newFilterType)
        {
            case PC_NORMAL_FILTER:
                self.internalFilter = [[GPUImageFilter alloc]init];
                break;
            case PC_YANGKE_FILTER:
                self.internalFilter = [[GPUImageFilter alloc]initWithFragmentShaderFromFile:@"yangke"];
                break;
            case PC_YINKE_FILTER:
                self.internalFilter = [[GPUImageFilter alloc]initWithFragmentShaderFromFile:@"yinke"];
                break;
            case PC_SIDEFACE_FILTER:
                self.internalFilter = [[GPUImageFilter alloc]initWithFragmentShaderFromFile:@"sideface"];
                break;
            default:
                break;
        }
        //切换到真正的filter
        [self performSelectorOnMainThread:@selector(swithToNewFilter) withObject:nil waitUntilDone:NO];
        
    });
}

//切换到相应的滤镜
- (void)swithToNewFilter
{
    //有still image 就处理后显示它
    if (self.stillImageSource != nil)
    {
        //切换为新滤镜,照片处理后显示到gpuImageView_HD上
        [self.stillImageSource removeTarget:self.filter];
        self.filter = self.internalFilter;
        [self.stillImageSource addTarget:self.filter];
        
        self.gpuImageView_HD.hidden = NO;
        [_filter addTarget:_gpuImageView_HD];
        [_stillImageSource processImage];
    }
    else
    {
        //切换到新滤镜，然后显示实时滤镜效果
        [self removeTarget:self.filter];
        self.filter = self.internalFilter;
        [_filter addTarget:_gpuImageView];
        [self addTarget:_filter];
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
    [self capturePhotoAsImageProcessedUpToFilter:(GPUImageOutput<GPUImageInput> *) _filter
                                 withOrientation:0
                           withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                              
                               self.rawImage = processedImage;
                               //调用一次，实际是为了显示照片到gpuImageView_HD上
                               [self swithFilter:_currentFilterType];
                               
                           }];
}

@end
