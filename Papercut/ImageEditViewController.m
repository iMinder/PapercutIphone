//
//  ImageEditViewController.m
//  Papercut
//
//  Created by jackie on 14-7-24.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "ImageEditViewController.h"
#import "GPUImage.h"
#import "UIImage+vImage.h"
#import "EditManager.h"

#import "WDPaintingManager.h"
#import "WDCanvas.h"
#import "WDDocument.h"
#import "WDPainting.h"

@interface ImageEditViewController ()
@property (nonatomic, strong) WDCanvas* canvas;
@property (nonatomic, strong) WDDocument *document;
@property (nonatomic, strong) WDPainting *painting;

@property (strong, nonatomic) EditManager *editManager;
- (void)addUndoWithImage:(UIImage *)image;

@end

@implementation ImageEditViewController
@synthesize canvas = canvas_;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.editManager = [[EditManager alloc]init];
    [self.undoButton setEnabled:NO];
    [self.redoButton setEnabled:NO];
    


  
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self.jotView loadImage:self.editImage];
    //[self.jotView setImage:self.editImage];
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 * 对图片进行膨胀处理
 */
- (IBAction)dilate:(id)sender {
//    GPUImageRGBDilationFilter *dilationFilter = [[GPUImageRGBDilationFilter alloc]init];
//    self.editImage = [dilationFilter imageByFilteringImage:self.editImage];
    //先保存快照，再进行变化
    
    //id __weak weakSelf = self;
//    [self.jotView exportToImageWithBackgroundColor:nil
//                                andBackgroundImage:nil
//                                        onComplete:^(UIImage * image) {
//                                           // [weakSelf addUndoWithImage:image];
//                                            [self addUndoWithImage:image];
//                                        }];
    
    
    self.editImage = [self.editImage dilate];
    //[self.jotView loadImage:self.editImage];
}

/**
 * 对图片进行腐蚀处理
 */
- (IBAction)erosion:(id)sender {
    
    //对比发现，使用GPU滤镜进行处理，内存上升很快
//    GPUImageRGBErosionFilter *erosionFilter = [[GPUImageRGBErosionFilter alloc]init];
//    self.editImage = [erosionFilter imageByFilteringImage:self.editImage];
//    id __weak weakSelf = self;
//    [self.jotView exportToImageWithBackgroundColor:nil
//                                andBackgroundImage:nil
//                                        onComplete:^(UIImage * image) {
//                                            //[weakSelf addUndoWithImage:image];
//                                            [self addUndoWithImage:image];
//                                        }];
    [self addUndoWithImage:self.editImage];
    
    self.editImage = [self.editImage erode];
    
    [self.jotView setImage:self.editImage];
  //  [self.jotView loadImage:self.editImage];
}

/**
 * 选择画笔的宽度
 */
- (IBAction)brush:(id)sender {
    
}

/**
 * 选择橡皮宽度
 */
- (IBAction)rubber:(id)sender {
}

- (IBAction)undo:(id)sender {
    UIImage *image = [self.editManager undoWithImage:self.editImage];
    if (image) {
        self.editImage = image;
         //[self.jotView loadImage:self.editImage];
        [self.jotView setImage:self.editImage];
        [self.redoButton setEnabled:YES];
    }
    else
    {
        [self.undoButton setEnabled:NO];
    }
    
}

- (IBAction)redo:(id)sender {
    UIImage *image = [self.editManager redoWithImage:self.editImage];
    if (image) {
        self.editImage = image;
        // [self.jotView loadImage:self.editImage];
            [self.jotView setImage:self.editImage];
        [self.undoButton setEnabled:YES];
    }
    else{
        [self.redoButton setEnabled:NO];
    }
    
}

- (void)addUndoWithImage:(UIImage *)image
{
    [self.editManager addUndoImage:image];
    [self.undoButton setEnabled:YES];
    
}

@end
