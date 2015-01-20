//
//  ShowCameraViewController.m
//  Papercut
//
//  Created by jackie on 14-5-26.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "ShowCameraViewController.h"
#import "ImageEditViewController.h"
#import "WDCanvasController.h"
#import "WDPaintingManager.h"
#import "UIImage+Resize.h"

@interface ShowCameraViewController()<UIGestureRecognizerDelegate>

//@property (strong, nonatomic)GPUImagestillImageCamera *stillImageCamera;
@property (strong, nonatomic)GPUImageView *cameraImageView;
@property (assign, nonatomic)BOOL isBackCamera;
@property (strong, nonatomic) PapercutVideoCamera *pcVideoCamera;

@property (assign, nonatomic)BOOL isPhotoDisplayed;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *albumChooseButton;
@property (weak, nonatomic) IBOutlet UIButton *usePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *backFrontButton;


@property (nonatomic) BOOL interfaceHiden;
- (void)changeButtonState;

@end

@implementation ShowCameraViewController

- (void)configureGuestures
{
    UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oneTap:)];
    oneFingerTap.numberOfTapsRequired = 1;
    oneFingerTap.delegate = self;
    [self.view addGestureRecognizer:oneFingerTap];
    self.interfaceHiden = NO;
}

- (void)hideInterface
{
    //[[self navigationController]setNavigationBarHidden:YES];
    [self.pcVideoCamera hideInterfaces];
    self.interfaceHiden = YES;
}
- (void)showInterface
{
    //[[self navigationController] setNavigationBarHidden:NO];
    [self.pcVideoCamera showInterfaces];
    self.interfaceHiden = NO;
}
- (void)oneTap:(UITapGestureRecognizer *)gesture
{
    if (self.interfaceHiden)
    {
        [self showInterface];
    }
    else
    {
        [self hideInterface];
    }
}

- (void)changeButtonState
{
    if (_isPhotoDisplayed)
    {
        self.takePhotoButton.hidden = YES;
        self.backFrontButton.hidden = YES;
        self.albumChooseButton.hidden = YES;
        self.usePhotoButton.hidden = NO;
    }
    else
    {
        self.takePhotoButton.hidden = NO;
        self.backFrontButton.hidden = NO;
        self.albumChooseButton.hidden = NO;
        self.usePhotoButton.hidden = YES;
    }
}

- (IBAction)dismissModalView:(id)sender
{
    if (_isPhotoDisplayed)
    {
        _isPhotoDisplayed = NO;
        [self changeButtonState];
        [_pcVideoCamera cancelAlbumPhotoAndGoBackToNormal];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.edgesForExtendedLayout = UIRectEdgeAll;
    [self configureGuestures];
}

- (void)awakeFromNib
{
    
    self.navigationItem.hidesBackButton = YES;
    [[self navigationController] setNavigationBarHidden:YES];
    self.isBackCamera = NO;
    self.isPhotoDisplayed = NO;
    //[self changeCameraBackOrFront:nil];
    self.pcVideoCamera = [[PapercutVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront highImageQuality:YES];
    
    if ([self.pcVideoCamera.captureSession canSetSessionPreset:AVAssetExportPreset1280x720])
    {
        [self.pcVideoCamera.captureSession setSessionPreset:AVAssetExportPreset1280x720];
    }
    
    //设置以防前置摄像头的偏转，默认是有偏转的
    _pcVideoCamera.delegate = self;
    _pcVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.view addSubview:self.pcVideoCamera.gpuImageView];
    
    
    [_pcVideoCamera startCameraCapture];
    [self.pcVideoCamera rotateCamera];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES];
}

/**
 * 按下拍照键
 */
- (IBAction)shootButtonPressed:(id)sender
{
    [self.pcVideoCamera takePhoto];
}

- (IBAction)showYangke:(id)sender
{
    [_pcVideoCamera swithFilter:PC_YANGKE_FILTER];
}

- (IBAction)showYinke:(id)sender
{
    [_pcVideoCamera swithFilter:PC_YINKE_FILTER];
}

- (IBAction)showNormal:(id)sender
{
    [_pcVideoCamera swithFilter:PC_NORMAL_FILTER];
}

- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.allowsEditing = NO;
    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark -- UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGSize imageSize = rawImage.size;
    
    if (imageSize.width > imageSize.height) {
        if (imageSize.width > 1024) {
            imageSize.height = (imageSize.height / imageSize.width) * 1024;
            imageSize.width = 1024;
        }
    } else {
        if (imageSize.height > 1024) {
            imageSize.width = (imageSize.width / imageSize.height) * 1024;
            imageSize.height = 1024;
        }
    }
    
    rawImage = [rawImage resizedImage:imageSize interpolationQuality:kCGInterpolationHigh];
    
    self.pcVideoCamera.rawImage = rawImage;
    [self.pcVideoCamera swithFilter:self.pcVideoCamera.currentFilterType];
    
    _isPhotoDisplayed = YES;
    [self changeButtonState];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeCameraBackOrFront:(id)sender
{
    UIButton *changeButton = (UIButton *)sender;
    changeButton.enabled = NO;
    [self.pcVideoCamera rotateCamera];
    changeButton.enabled = YES;
}

- (IBAction)usePhoto:(id)sender
{
    //跳转到下一页
    //[self.pcVideoCamera saveCurrentStillImage];
    //[self performSegueWithIdentifier:@"EditImageIdentifier" sender:self];
    
    WDCanvasController *canvasController = [[WDCanvasController alloc] init];
    [self.navigationController pushViewController:canvasController animated:YES];
    
    CGSize size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    [[WDPaintingManager sharedInstance] createNewPaintingWithSize:size afterSave:^(WDDocument *document) {
        // set the document before setting the editing flag
        canvasController.document = document;
        canvasController.editing = YES;
        [canvasController insertImageToCavas:[self imageWithRedBorder:
         [self.pcVideoCamera editImage]]];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditImageIdentifier"]) {
       // UIViewController *VC = segue.destinationViewController;
        //[self.navigationController pushViewController:VC animated:YES];
        ImageEditViewController *VC = (ImageEditViewController*)segue.destinationViewController;
        VC.editImage = [self.pcVideoCamera editImage];
    }
}
#pragma mark -- PCVideoCameraDelegate Method

- (void)PCVideCameraWillStartCaptureStillImage:(PapercutVideoCamera *)videoCamera
{
    _isPhotoDisplayed = YES;
    [self changeButtonState];
}

- (void)PCVideCameraDidFinishCaptureStillImage:(PapercutVideoCamera *)videoCamera
{
    
}

- (void)PCVideCameraDidSaveCaptureStillImage:(PapercutVideoCamera *)videoCamera withError:(NSError *)error
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:[error localizedDescription] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    else
    {//跳转到下一页
        
    }
}

- (UIImage *)imageWithRedBorder:(UIImage *)source
{
    //1 绘制图形上下文
    CGSize size = source.size;
    //让其成为当前上下文
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //2 进行stoke
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 10);
    CGContextStrokeRect(context, rect);
    //CGContextStrokePath(context);
    
    //3 获取当前图片
    UIImage *borderImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return borderImg;
}
@end
