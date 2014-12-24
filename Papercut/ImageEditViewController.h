//
//  ImageEditViewController.h
//  Papercut
//
//  Created by jackie on 14-7-24.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JotView;
@interface ImageEditViewController : UIViewController

@property (strong, nonatomic) UIImage *editImage;

@property (weak, nonatomic) IBOutlet UIImageView *jotView;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

- (IBAction)dilate:(id)sender;
- (IBAction)erosion:(id)sender;
- (IBAction)brush:(id)sender;
- (IBAction)rubber:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

@end
