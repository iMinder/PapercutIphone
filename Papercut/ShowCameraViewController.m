//
//  ShowCameraViewController.m
//  Papercut
//
//  Created by jackie on 14-5-26.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "ShowCameraViewController.h"
#import "WDCanvasController.h"
#import "WDPaintingManager.h"
#import "UIImage+Resize.h"
#import "YangKeFilter.h"
#import "YinKeFilter.h"

static CGFloat const RadiusFactor = 15;
#define TakePhotoTag 0
#define UsePhotoTag 20

@interface ShowCameraViewController()<UIGestureRecognizerDelegate>

@property (strong, nonatomic)GPUImageView *cameraImageView;
@property (strong, nonatomic) GPUImageStillCamera *cameraSource;
@property (strong, nonatomic) GPUImagePicture *stillImageSource;
@property (assign, nonatomic) GPUImageOutput *currentSource;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UILabel *takePhotoTitle;

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic, strong) dispatch_queue_t filterQueue;

@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *albumChooseButton;
@property (weak, nonatomic) IBOutlet UIButton *backFrontButton;
@property (weak, nonatomic) IBOutlet UISlider *filterSlider;

@property (nonatomic, assign)PapercutFilterType currentType;

@property (strong, nonatomic) GPUImageFilter *normalFilter;
@property (strong, nonatomic) GPUImageAdaptiveThresholdFilter *sketchFilter;
@property (assign, nonatomic) GPUImageFilter *lineFirstFilter;
@property (assign, nonatomic) GPUImageFilter *lineLastFilter;
@property (strong, nonatomic) YangKeFilter *yangKeFilter;
@property (strong, nonatomic) YinKeFilter *yinKeFilter;
@property (strong, nonatomic) GPUImageMedianFilter *medianFilter;

@property (nonatomic) BOOL interfaceHiden;

@end

@implementation ShowCameraViewController

#pragma mark - set up
- (YangKeFilter *)yangKeFilter
{
    if (!_yangKeFilter)
    {
        _yangKeFilter = [YangKeFilter new];
    }
    return _yangKeFilter;
}

- (YinKeFilter *)yinKeFilter
{
    if (!_yinKeFilter)
    {
        _yinKeFilter = [YinKeFilter new];
    }
    return _yinKeFilter;
}

- (GPUImageAdaptiveThresholdFilter *)sketchFilter
{
    if (!_sketchFilter)
    {
        _sketchFilter = [GPUImageAdaptiveThresholdFilter new];
        _sketchFilter.blurRadiusInPixels = self.filterSlider.value * RadiusFactor;
    }
    return _sketchFilter;
}

- (GPUImageFilter *)normalFilter
{
    if (!_normalFilter) {
        _normalFilter = [GPUImageFilter new];
    }
    return _normalFilter;
}
- (GPUImageStillCamera *)cameraSource
{
    if (!_cameraSource )
    {
        _cameraSource = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480
                                                    cameraPosition:AVCaptureDevicePositionBack];
        _cameraSource.outputImageOrientation = UIInterfaceOrientationPortrait;
    }
    return _cameraSource;
}

- (GPUImageMedianFilter *)medianFilter
{
    if (!_medianFilter) {
        _medianFilter = [GPUImageMedianFilter new];
        
    }
    return _medianFilter;
}
- (void)setUp
{
    self.navigationItem.hidesBackButton = YES;
    [[self navigationController] setNavigationBarHidden:YES];
    // 1 .初始化摄像头
    self.filterQueue = dispatch_queue_create("com.papercut.filterqueue", NULL);
        
    // 2.初始化cameraView，设置
    
    // 4 .configure guesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(showOrHideSlider:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector (showImagePickerForPhotoPicker:)];
    [self.cameraView addGestureRecognizer:tap];
    [self.view addGestureRecognizer:longPress];
    [(GPUImageView *)self.cameraView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    
    //5 .竖直显示slider
    self.filterSlider.transform = CGAffineTransformRotate(self.filterSlider.transform, M_PI_2);
    
    //6 . 设置filterview的透明度
    self.filterView.layer.opacity = 0.6;
    
    _currentType = kPapercutNormalFilter;
    [self userCameraSource];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (IBAction)back:(UIButton *)sender
{
    if (self.stillImageSource)
    {
        [self userCameraSource];
    }
    else
    {
        //关闭摄像头使用
        [self.cameraSource stopCameraCapture];
        self.cameraSource = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark - Cameram Options
- (IBAction)rotate:(UIButton *)sender
{
    sender.enabled = NO;
    [self.cameraSource rotateCamera];
    sender.enabled = YES;
}

- (void)showOrHideSlider:(UIGestureRecognizer *)gesture
{
    self.filterSlider.hidden = !self.filterSlider.hidden;
 
}

- (IBAction)sliderValueChange:(UISlider *)sender
{
    self.sketchFilter.blurRadiusInPixels = RadiusFactor * sender.value;
    //如果静态照片处理，更新处理
    [self processImage];
}

- (IBAction)takePhoto:(UIButton *)sender
{
    if (sender.tag == TakePhotoTag)
    {
        [sender setEnabled:NO];
        __weak typeof(self) weakSelf = self;
        [self.cameraSource capturePhotoAsImageProcessedUpToFilter:self.normalFilter
                                           withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                                               sender.tag = UsePhotoTag;
                                               [sender setEnabled:YES];
                                               [weakSelf useStillImageSourceWithImage:processedImage];
                                           }];
    }
    else
    {
        //使用图片
        
        WDCanvasController *canvasController = [[WDCanvasController alloc] init];
        [self.navigationController pushViewController:canvasController animated:YES];
    
        CGSize size = CGSizeMake(480, 640);
        [[WDPaintingManager sharedInstance] createNewPaintingWithSize:size afterSave:^(WDDocument *document) {
            // set the document before setting the editing flag
            canvasController.document = document;
            canvasController.editing = YES;
        
            GPUImageFilter *filter = [self lastFilter];
            [filter useNextFrameForImageCapture];
            [self.stillImageSource processImage];
            UIImage *image = [filter imageFromCurrentFramebuffer];
            image = [image imageWithRedBorder];
            [canvasController insertImageToCavas:image];
        }];
    }
}

- (GPUImageFilter *)lastFilter
{
    switch (_currentType) {
        case kPapercutYinKeFilter:
            return self.yinKeFilter;
            break;
        case kPapercutNormalFilter:
            return self.normalFilter;
            break;
        case kPapercutYangKeFilter:
            return self.yangKeFilter;
            break;
        default:
            break;
    }
    return self.normalFilter;
}
#pragma mark - Change Filter

- (void)showFilterView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.filterView.center = CGPointMake(self.filterView.center.x, self.filterView.center.y - self.filterView.frame.size.height);
        self.filterView.alpha = 0.6;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideFilterView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.filterView.center = CGPointMake(self.filterView.center.x, self.filterView.center.y + self.filterView.frame.size.height);
        self.filterView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];

}

- (IBAction)effectInterfaceChange:(UIButton *)effectBtn
{
    if ((self.filterView.alpha == 0.0))
    {
        [effectBtn setBackgroundImage:[UIImage imageNamed:@"btn_effect_hide"] forState:UIControlStateNormal];
        
        [self showFilterView];
    }
    else
    {
        [effectBtn setBackgroundImage:[UIImage imageNamed:@"btn_effect_show"] forState:UIControlStateNormal];
        [self hideFilterView];
    }
}


- (void)userCameraSource
{
    [self.stillImageSource removeAllTargets];
    self.stillImageSource = nil;
    self.currentSource = self.cameraSource;
    [self.cameraSource startCameraCapture];
    
    //拍照图片变回来
    self.takePhotoButton.tag = TakePhotoTag;
    [self.takePhotoButton setBackgroundImage:[UIImage imageNamed:@"btn_camera_take"]
                                    forState:UIControlStateNormal];
    [self.takePhotoTitle setText:NSLocalizedString(@"拍照", @"拍照")];
    [self.backFrontButton setHidden:NO];
    [self beginFilter];
}
- (void)useStillImageSourceWithImage:(UIImage *)rawImage
{
    [self.cameraSource stopCameraCapture];
    [self.cameraSource removeAllTargets];
    self.cameraSource = nil;
    
    self.stillImageSource = [[GPUImagePicture alloc]initWithImage:rawImage];
    self.currentSource = self.stillImageSource;

    self.takePhotoButton.tag = UsePhotoTag;
    [self.takePhotoButton setBackgroundImage:[UIImage imageNamed:@"btn_camera_ok"]
                                    forState:UIControlStateNormal];
    [self.takePhotoTitle setText:NSLocalizedString(@"确认", @"确认")];
    [self.backFrontButton setHidden:YES];
    [self beginFilter];
}

- (void)beginFilter
{
    switch (self.currentType)
    {
        case kPapercutNormalFilter:
            [self noFilter:nil];
            break;
        case kPapercutYinKeFilter:
            [self yinke:nil];
            break;
        case kPapercutYangKeFilter:
            [self yangke:nil];
            break;
        default:
            break;
    }
}

- (void)processImage
{
    if (self.stillImageSource && self.currentSource == self.stillImageSource)
     {
         [self.stillImageSource processImage];
     }
}

- (IBAction)yangke:(UIButton *)sender
{
    sender.enabled = NO;
    self.currentType = kPapercutYangKeFilter;
    dispatch_async(self.filterQueue, ^{
        [self.normalFilter removeAllTargets];
        [self.sketchFilter removeAllTargets];
        [self.yangKeFilter removeAllTargets];
        //[self.medianFilter removeAllTargets];
        [self.normalFilter addTarget:self.sketchFilter];
        //[self.normalFilter addTarget:self.medianFilter];
       // [self.medianFilter addTarget:self.sketchFilter];
        [self.sketchFilter addTarget:self.yangKeFilter];
        [self.yangKeFilter addTarget:self.medianFilter];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.currentSource addTarget:self.normalFilter];
            //[self.yangKeFilter addTarget: (GPUImageView *)self.cameraView];
            [self.medianFilter addTarget:(GPUImageView *)self.cameraView];
            [self processImage];
            sender.enabled = YES;
        });
    });
}

- (IBAction)yinke:(UIButton *)sender
{
    [sender setEnabled:NO];
    self.currentType = kPapercutYinKeFilter;
    dispatch_async(self.filterQueue, ^{
        [self.normalFilter removeAllTargets];
        [self.sketchFilter removeAllTargets];
        [self.yinKeFilter removeAllTargets];
        [self.normalFilter addTarget:self.sketchFilter];
        [self.sketchFilter addTarget:self.yinKeFilter];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.currentSource addTarget:self.normalFilter];
            [self.yinKeFilter addTarget:(GPUImageView *)self.cameraView];
            [self processImage];
            [sender setEnabled:YES];
        });
    });
}

- (IBAction)noFilter:(UIButton *)sender
{
    [sender setEnabled:NO];
    self.currentType = kPapercutNormalFilter;
    dispatch_async(self.filterQueue, ^{
        [self.normalFilter removeAllTargets];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.currentSource addTarget:self.normalFilter];
            [self.normalFilter addTarget:(GPUImageView *)self.cameraView];
            [self processImage];
            [sender setEnabled:YES];
        });
    
    });
}



#pragma mark UIImagePicker

- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.allowsEditing = NO;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGSize imageSize = rawImage.size;
    
    if (imageSize.width > imageSize.height)
    {
        if (imageSize.width > 2048)
        {
            imageSize.height = (imageSize.height / imageSize.width) * 2048;
            imageSize.width = 2048;
        }
    }
    else
    {
        if (imageSize.height > 2048)
        {
            imageSize.width = (imageSize.width / imageSize.height) * 2048;
            imageSize.height = 2048;
        }
    }
    
    rawImage = [rawImage resizedImage:imageSize interpolationQuality:kCGInterpolationHigh];
    [self useStillImageSourceWithImage:rawImage];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation UIImage(RedBoarder)

- (UIImage *)imageWithRedBorder
{

    //1 绘制图形上下文
    CGSize size = self.size;
    
    NSAssert( size.height > 0 && size.width > 0, @"图片至少需要1像素的宽度或高度,不可以为空");
    
    //让其成为当前上下文
    UIGraphicsBeginImageContextWithOptions(size, 1.0, [UIScreen mainScreen].scale);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [self drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //2 进行stoke
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 10);
    CGContextStrokeRect(context, rect);
    
    //3 获取当前图片
    UIImage *borderImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return borderImg;
}
@end
