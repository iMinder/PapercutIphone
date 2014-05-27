//
//  CameraViewController.m
//  Papercut
//
//  Created by jackie on 14-5-26.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "CameraViewController.h"
#import "ShowCameraViewController.h"

@interface CameraViewController()

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation CameraViewController

//- (IBAction)showImagePickerForCamera:(id)sender
//{
//   // [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
//    ShowCameraViewController *cameraViewController = [[ShowCameraViewController alloc]init];
//    cameraViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    [self presentViewController:cameraViewController animated:YES completion:nil];
//}

- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegateMethod

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获得图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //关闭界面
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
