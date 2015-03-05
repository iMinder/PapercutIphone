//
//  GuideViewController.m
//  Papercut
//
//  Created by jackie on 15/3/3.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "GuideViewController.h"

@interface GuideViewController ()<UIScrollViewDelegate>

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self setUp];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUp];
}

- (void)setUp
{
    self.scrollView.frame = self.view.bounds;
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 40, 37)];
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 4;
    self.pageControl.center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 40);
    [self.pageControl setTintColor:[UIColor blackColor]];
    
    [self.view addSubview:self.pageControl];
    for (int i = 1; i < 5; i++) {
        NSString *imagePath = [NSString stringWithFormat:@"guide_%d%d", i,i];
        UIImage *image = [UIImage imageNamed:imagePath];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(self.scrollView.frame.size.width * (i - 1), 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        if (i == 4) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[UIImage imageNamed:@"guide_begin10"] forState:UIControlStateNormal];
            button.frame = CGRectMake(0, 0, 113, 44);
            button.center = CGPointMake(imageView.frame.size.width / 2, imageView.frame.size.height - 80);
            [button addTarget:self action:@selector(dismissModalView:) forControlEvents:UIControlEventTouchUpInside];
            imageView.userInteractionEnabled = YES;
            [imageView addSubview:button];
        }
        [self.scrollView addSubview:imageView];
    }
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * 4, self.scrollView.frame.size.height)];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dismissModalView:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstShow"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
     
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   self.pageControl.currentPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
}
    
@end
