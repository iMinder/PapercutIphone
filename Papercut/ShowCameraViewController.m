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
@property (weak, nonatomic) IBOutlet UIImageView *resultImage;

@end

@implementation ShowCameraViewController

- (IBAction)dismissModalView:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)awakeFromNib
{

    self.cameraImageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 380)];
    self.stillImageCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.stillImageCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.view addSubview:self.cameraImageView];
    self.filter = [[GPUImageFilter alloc]initWithFragmentShaderFromFile:@"Shader1"];
    
    [_filter forceProcessingAtSize:self.cameraImageView.sizeInPixels];
    [self.stillImageCamera addTarget:_filter];
    [_filter addTarget:self.cameraImageView];
    
    [self.stillImageCamera startCameraCapture];

}

/**
 * 按下拍照键
 */
- (IBAction)shootButtonPressed:(id)sender
{
    [self.stillImageCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        //self.cameraImageView = processedImage;
        [self.view bringSubviewToFront:self.resultImage];
        self.cameraImageView.hidden = YES;
        self.resultImage.hidden = NO;
        self.resultImage.image = processedImage;
    }];
}

@end
