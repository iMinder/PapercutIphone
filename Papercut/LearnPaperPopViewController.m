//
//  LearnPaperPopViewController.m
//  Papercut
//
//  Created by jackie on 15/2/16.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "LearnPaperPopViewController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"

@interface LearnPaperPopViewController()
@property (weak, nonatomic)  UIImageView *show;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, assign) NSInteger currentIndex;

@end
@implementation LearnPaperPopViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUp];
}

- (void)dealloc
{
    [SVProgressHUD dismiss];

}

- (void)setUp
{
    
    // 1.添加imageview
    CGRect frame = CGRectMake(0,  self.toolBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.toolBar.frame.size.height);
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:frame];
    [imgView setImage:[UIImage imageNamed:@"blank_page_h"]];
    [self.view addSubview:imgView];
  
    //2 . 添加显示imageview
    UIImageView *showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 330, 250)];
    showImgView.center  = imgView.center;
    [showImgView setImage:[UIImage imageNamed:@"1"]];
    [self.view addSubview:showImgView];
    
    self.show = showImgView;
    
   // 3. 设置guesture
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];

    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
   // 4 .加载资源
    NSString *path = [[NSBundle mainBundle]pathForResource:@"LearnDetail" ofType:@"plist"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        if (dic) {
            NSString *key = [NSString stringWithFormat:@"%d", _index];
            self.items = [dic objectForKey:key];
            if (self.items) {
                NSMutableArray *urls = [NSMutableArray new];
                [self.items enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                    [urls addObject:[NSURL URLWithString:obj]];
                }];
                 [imgView sd_downloadImagesWithURLs:urls];
            }
        }
    }
}

#pragma mark - Prefere Land

- (BOOL)shouldAutorotate
{
    return  NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation

{
    return UIInterfaceOrientationLandscapeRight;
}

- (IBAction)dismiss:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
    
}
- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
    if ([self.items count ] == 0 ) {
        [SVProgressHUD showErrorWithStatus:@"没有可显示的教程"];
        return;
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
       //下一个
        self.currentIndex =  (self.currentIndex + 1) % self.items.count;
        [SVProgressHUD showWithStatus:@"加载中..."];
        NSURL *url = [NSURL URLWithString:self.items[_currentIndex]];
        __weak typeof(self) weakSelf = self;
        [self.show sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [SVProgressHUD dismiss];
                [weakSelf.show setImage:image];
            }
        }];
        
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionRight){
        NSLog(@"privous");
    }
}

@end
