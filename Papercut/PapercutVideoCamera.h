//
//  PCVideoCamera.h
//  Papercut
//
//  Created by jackie on 14-5-28.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "PapercutFilter.h"

@class  PCVideoCamera;

@protocol PCVideoCameraDelegate <NSObject>

- (void)PCVideCameraWillStartCaptureStillImage:(PCVideoCamera *)videoCamera;
- (void)PCVideCameraDidFinishCaptureStillImage:(PCVideoCamera *)videoCamera;
- (void)PCVideCameraDidSaveCaptureStillImage:(PCVideoCamera *)videoCamera withError:(NSError *)error;

@end

@class YinKeFilter;
@class YangKeFilter;

@interface PCVideoCamera : GPUImageStillCamera

@property (strong, nonatomic) GPUImageAdaptiveThresholdFilter *sketchFilter;
@property (assign, nonatomic) GPUImageFilter *lineFirstFilter;
@property (assign, nonatomic) GPUImageFilter *lineLastFilter;
@property (strong, nonatomic) GPUImageFilter *dilationFilter;
@property (strong, nonatomic) GPUImageFilter *dilationFilter2;
@property (strong, nonatomic) GPUImageFilter *erosionFilter;
@property (strong, nonatomic) GPUImageFilter *erosionFilter2;
@property (strong, nonatomic) YangKeFilter *yangKeFilter;
@property (strong, nonatomic) YinKeFilter *yinKeFilter;
@property (strong, nonatomic, readonly) GPUImageView *gpuImageView;
@property (strong, nonatomic, readonly) GPUImageView *gpuImageView_HD;
@property (strong, nonatomic) UIImage *rawImage;
@property (nonatomic, assign) PCFilterType currentFilterType;
@property (strong, nonatomic) GPUImageFilter *normalFilter;

@property (weak, nonatomic) id delegate;

- (id)initWithSessionPreset:(NSString *)sessionPreset cameraPosition:(AVCaptureDevicePosition)cameraPosition highImageQuality:(BOOL)isHighQuality;
- (void)swithFilter:(PCFilterType)filterType;
- (void)takePhoto;
- (void)cancelAlbumPhotoAndGoBackToNormal;
- (void)saveCurrentStillImage;
- (UIImage *)editImage;
@end
