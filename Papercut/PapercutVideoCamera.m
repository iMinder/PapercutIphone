
//
//  PCVideoCamera.m
//  Papercut
//
//  Created by jackie on 14-5-28.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "PapercutVideoCamera.h"
#import "YangKeFilter.h"
#import "YinKeFilter.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#define RADIUS_FACTOR 15

@interface PapercutVideoCamera()

@property (strong, nonatomic, readwrite) GPUImageView *gpuImageView;
@property (strong, nonatomic, readwrite) GPUImageView *gpuImageView_HD;
@property (strong, nonatomic) GPUImagePicture *stillImageSource;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) dispatch_queue_t prepareFilterQueue;
@property (strong, nonatomic) AVMutableComposition *mutableComposition;
@property (strong, nonatomic) AVAssetExportSession *assetExportSession;
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) UISlider *radiuSlider;
- (void)forceSwitchToNewFilter:(PCFilterType)newFilterType;

@end

@implementation PapercutVideoCamera

- (ALAssetsLibrary *)library
{
    if (!_library) {
        _library = [[ALAssetsLibrary alloc]init];
    }
    return _library;
}

- (GPUImageAdaptiveThresholdFilter *)sketchFilter
{
    if (!_sketchFilter) {
        _sketchFilter = [[GPUImageAdaptiveThresholdFilter alloc]init];
        
    }
    return _sketchFilter;
}
- (YangKeFilter *)yangKeFilter
{
    if (!_yangKeFilter) {
        _yangKeFilter = [[YangKeFilter alloc]init];
        
    }
    return _yangKeFilter;
}

- (GPUImageFilter *)normalFilter
{

    static GPUImageFilter* NormalFilterInstance = nil;
    static dispatch_once_t normal_queue;
    dispatch_once(&normal_queue, ^{
        NormalFilterInstance  = [[GPUImageFilter alloc]init];
    });
    return NormalFilterInstance;
}
- (YinKeFilter *)yinKeFilter
{
    if (!_yinKeFilter) {
        _yinKeFilter = [[YinKeFilter alloc]init];
        
    }
    return _yinKeFilter;
}

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition highImageQuality:(BOOL)isHighQuality
{
    self = [super initWithSessionPreset:sessionPreset cameraPosition:cameraPosition];
    
    if (self == nil)
    {
        return  nil;
    }
    
    self.prepareFilterQueue  = dispatch_queue_create("com.papercut.prepareFilterQueue", NULL);
    
    //设置view
    self.gpuImageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 440)];
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
    
    //用于输出，当拍照时，用gpuImageView_HD显示结果
    self.gpuImageView_HD = [[GPUImageView alloc]initWithFrame:self.gpuImageView.bounds];
    self.gpuImageView_HD.hidden = YES;
    [self.gpuImageView addSubview:self.gpuImageView_HD];
    
    //设置默认滤镜无
    _currentFilterType = PC_NORMAL_FILTER;
    _lineFirstFilter = self.normalFilter;
    _lineLastFilter = self.normalFilter;
    [self swithToNewFilter];
    
    [self configureViews];
    
    return self;
}

- (void)configureViews
{
    self.radiuSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 100, 270, 31)];
    [self.radiuSlider addTarget:self action:@selector(updateRadius:) forControlEvents:UIControlEventValueChanged];
    self.radiuSlider.center = CGPointMake(SCREEN_WIDTH - 20, self.gpuImageView.center.y);
    self.radiuSlider.minimumValue = 0.0;
    self.radiuSlider.maximumValue = 1.0;
    self.radiuSlider.value = 0.5;
    self.radiuSlider.transform = CGAffineTransformRotate(self.radiuSlider.transform, M_PI_2);
    [self updateFilterDepth:self.radiuSlider.value * RADIUS_FACTOR];
    [self.gpuImageView addSubview:self.radiuSlider];
    
}

- (void)updateRadius:(UISlider *)slider
{
    [self updateFilterDepth:slider.value * RADIUS_FACTOR];
}

- (void)swithFilter:(PCFilterType)normalFilterType
{
    //如果是从相册选取的一张照片，就对照片进行滤镜处理,如果拍照
    if (self.rawImage != nil && self.stillImageSource == nil)
    {
        [self pauseCameraCapture];
        self.stillImageSource = [[GPUImagePicture alloc]initWithImage:self.rawImage];
    }
    else
    {
        //如果当前滤镜效果和filtrType相同，就不变
        if (_currentFilterType == normalFilterType)
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
        //移除正常滤镜的下一个目标
        [self.normalFilter removeAllTargets];
        
        switch (newFilterType)
        {
            case PC_NORMAL_FILTER:
            {
                //无处理效
                _lineLastFilter = self.normalFilter;
                //
                break;
            }
            case PC_YANGKE_FILTER:
            {
                //阳刻效果 素描效果－> 阳刻
                
                [self.sketchFilter removeAllTargets];
                [self.normalFilter addTarget:self.sketchFilter];
                //在使用之前，移除之后的所有目标
              
                [self.yangKeFilter removeAllTargets];
                [self.sketchFilter addTarget:self.yangKeFilter];
    
                _lineLastFilter = self.yangKeFilter;
                break;
            }

            case PC_YINKE_FILTER:
            {
                //阴刻效果 素描->阴刻剪纸剪纸->腐蚀
                
                [self.sketchFilter removeAllTargets];
                [self.normalFilter addTarget:self.sketchFilter];
                
                [self.yinKeFilter removeAllTargets];
                [self.sketchFilter addTarget:self.yinKeFilter];
                
                _lineLastFilter = self.yinKeFilter;
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
    [self removeAllTargets];
    [self.stillImageSource removeAllTargets];
    
    //静态图片显示
    if (self.stillImageSource != nil)
    {
        //切换为新滤镜,照片处理后显示到gpuImageView_HD上
        [self.stillImageSource addTarget:self.lineFirstFilter];
        self.gpuImageView_HD.hidden = NO;
        [self.lineLastFilter addTarget:_gpuImageView_HD];
        [_stillImageSource processImage];
    }
    else
    {
        //切换到新滤镜，然后显示实时滤镜效果
        [self addTarget:_lineFirstFilter];
        [_lineLastFilter addTarget:_gpuImageView];
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
    //开始拍照,注意，传递进去的一定是当前最后一个滤镜的输出，否则一直获取为空
    __weak PapercutVideoCamera *weakSelf = self;
    [self capturePhotoAsImageProcessedUpToFilter:(GPUImageOutput<GPUImageInput> *) _lineFirstFilter
                                 withOrientation:0
                           withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                               
                               weakSelf.rawImage = processedImage;
                               //调用一次，实际是为了显示照片到gpuImageView_HD上
                               [weakSelf.lineLastFilter removeAllTargets];
                            
                               [weakSelf swithFilter:_currentFilterType];
                               
                               if ([weakSelf.delegate respondsToSelector:@selector(PCVideCameraDidFinishCaptureStillImage:)])
                               {
                                   [weakSelf.delegate PCVideCameraDidFinishCaptureStillImage:self];
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
    [self resumeCameraCapture];
}

/**
 * 保存图片
 */
- (void)saveCurrentStillImage
{
    if (self.rawImage == nil)
    {
        return;
    }
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
    
    [self.library saveImage:self.rawImage toAlbum:prodName withCompletionBlock:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(PCVideCameraDidSaveCaptureStillImage:withError:)]) {
            [self.delegate PCVideCameraDidSaveCaptureStillImage:self withError:error];
        }
    }];
}

/**
 * 静态图片的保存
 */
- (UIImage *)editImage
{
    UIImage *retImage;
    [_lineLastFilter useNextFrameForImageCapture];
    [self.stillImageSource processImage];
    retImage = [_lineLastFilter imageFromCurrentFramebuffer];
    return retImage;
}

#pragma mark - 更新滤镜强度
- (void)updateFilterDepth:(float)depth
{
    self.sketchFilter.blurRadiusInPixels = depth;
    [self editImage];
}

#pragma mark - 视图布局显示
- (void)hideInterfaces
{
    [self.radiuSlider setHidden:YES];
}
- (void)showInterfaces
{
    [self.radiuSlider setHidden:NO];
}

@end
