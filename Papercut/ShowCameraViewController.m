//
//  ShowCameraViewController.m
//  Papercut
//
//  Created by jackie on 14-5-26.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "ShowCameraViewController.h"


@interface ShowCameraViewController()

//@property (strong, nonatomic)GPUImagestillImageCamera *stillImageCamera;
@property (strong, nonatomic)GPUImageView *cameraImageView;
@property (strong, nonatomic)GPUImageFilter *filter;
@property (strong, nonatomic)GPUImageStillCamera *stillImageCamera;
@property (assign, nonatomic)BOOL isBackCamera;
@property (strong, nonatomic) PCVideoCamera *pcVideoCamera;

@property (assign, nonatomic)BOOL isPhotoDisplayed;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *albumChooseButton;
@property (weak, nonatomic) IBOutlet UIButton *usePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *backFrontButton;

- (void)changeButtonState;

@end

@implementation ShowCameraViewController

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
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)awakeFromNib
{
    self.isBackCamera = YES;
    self.isPhotoDisplayed = NO;
    [self changeCameraBackOrFront:nil];
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
    if (_isBackCamera)
    {
        self.isBackCamera = NO;
        self.pcVideoCamera = [[PCVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack highImageQuality:YES];
    }
    else
    {
        self.isBackCamera  = YES;
        self.pcVideoCamera = [[PCVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront highImageQuality:YES];
        
    }
    //设置以防前置摄像头的偏转，默认是有偏转的
    _pcVideoCamera.delegate = self;
    _pcVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.view addSubview:self.pcVideoCamera.gpuImageView];
    [_pcVideoCamera startCameraCapture];
    changeButton.enabled = YES;
}

- (IBAction)usePhoto:(id)sender
{
    
}
#pragma mark -- PCVideoCameraDelegate Method

- (void)PCVideCameraWillStartCaptureStillImage:(PCVideoCamera *)videoCamera
{
    _isPhotoDisplayed = YES;
    [self changeButtonState];
}

- (void)PCVideCameraDidFinishCaptureStillImage:(PCVideoCamera *)videoCamera
{
    
}

- (void)PCVideCameraDidSaveCaptureStillImage:(PCVideoCamera *)videoCamera
{
    
}

@end
