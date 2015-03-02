//
//  LearnPaperPopViewController.m
//  Papercut
//
//  Created by jackie on 15/2/16.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "LearnPaperPopViewController.h"
#import "UIImageView+WebCache.h"

@interface LearnPaperPopViewController()
@property (weak, nonatomic)  UIImageView *show;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, weak)IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setUp
{
    // 1.添加imageview
    CGRect frame = CGRectMake(0,  self.toolBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.toolBar.frame.size.height);
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:frame];
    [imgView setImage:[UIImage imageNamed:@"blank_page_h"]];
    [self.view insertSubview:imgView atIndex:0];
    //2 . 添加显示imageview
    UIImageView *showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 330, 245)];
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
            NSString *key = [NSString stringWithFormat:@"%ld", (long)_index];
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
    [self showCurrentImage];
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

- (void)showCurrentImage
{
    [self.indicator startAnimating];
    self.infoLabel.text = @"努力加载中...";
    
    NSURL *url = [NSURL URLWithString:self.items[_currentIndex]];
    __weak typeof(self) weakSelf = self;
    [self.show sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
           
            [weakSelf.show setImage:image];
            [weakSelf.indicator stopAnimating];
            self.infoLabel.text = [NSString stringWithFormat:@"%@ %d / %d",self.name, _currentIndex + 1, [self.items count]];
            
        }
    }];
}

- (void)nextOne
{
    [self checkItems];
    _currentIndex =  (_currentIndex + 1) % self.items.count;
    [self showCurrentImage];
}

- (void)checkItems
{
    if ([self.items count ] == 0 ) {
        self.infoLabel.text = @"没有可显示的数据...";
        return;
    }
}

- (void)prvious_
{
    [self checkItems];
    if (self.currentIndex == 0) {
        _currentIndex = [self.items count] - 1;
        
    }else
    {
        self.currentIndex --;
    }
    [self showCurrentImage];
}

- (IBAction)next:(id)sender
{
    [self nextOne];
}

- (IBAction)previous:(id)sender
{
    [self prvious_];
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
       //下一个
        [self nextOne];
        
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionRight){
        [self prvious_];
    }
}

@end
