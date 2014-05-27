//
//  ShowCameraViewController.m
//  Papercut
//
//  Created by jackie on 14-5-26.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "ShowCameraViewController.h"

@interface ShowCameraViewController()

@property (strong, nonatomic)GPUImageVideoCamera *videoCamera;
@property (strong, nonatomic)GPUImageView *cameraImageView;
@property (strong, nonatomic)GPUImageFilter *filter;
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
    self.cameraImageView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 64, 320, 380)];
    self.videoCamera = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [self.view addSubview:self.cameraImageView];
    
    self.filter = [[GPUImageFilter alloc]initWithFragmentShaderFromFile:@"Shader1"];
    [_filter forceProcessingAtSize:self.cameraImageView.sizeInPixels];
   
    [self.videoCamera addTarget:_filter];
    [_filter addTarget:self.cameraImageView];
    
    [self.videoCamera startCameraCapture];
    
}

@end
