//
//  LearnPaperCutViewController.m
//  Papercut
//
//  Created by jackie on 15/1/20.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "LearnPaperCutViewController.h"
#import "WDColorPickerController.h"
#import "WDColor.h"
#import "PaperToolBar.h"

typedef enum : NSUInteger {
    PaperToolTypeNone,
    PaperToolTypeFold,
    PaperToolTypeDecorate,
} PaperToolType;

@interface LearnPaperCutViewController ()<UIGestureRecognizerDelegate, PaperToolBarDelegate>

@property (nonatomic)BOOL isColorSet;
@property (nonatomic)PaperToolBar *paperToolBar;
@property (nonatomic)PaperToolType currentType;
@end

@implementation LearnPaperCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self configureGuestures];
    [self.navigationController setToolbarHidden:NO];
    self.currentType = PaperToolTypeNone;
    //self.navigationController.hidesBarsOnTap = YES;
}

- (PaperToolBar *)paperToolBar
{
    if (!_paperToolBar)
    {
        _paperToolBar = [PaperToolBar bottomPaperBarWithTool:self.navigationController.toolbar];
        _paperToolBar.delegate = self;
        [self.view addSubview:_paperToolBar];
    }
    return _paperToolBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.paperToolBar = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark interface update

//- (void)configureGuestures
//{
//    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeInterface:)];
//    oneTap.delegate = self;
//    oneTap.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:oneTap];
//}

- (void)showColorPicker
{
    if (!self.isColorSet)
    {
        self.isColorSet = YES;
        WDColorPickerController *colorPicker = [[WDColorPickerController alloc] initWithNibName:@"ColorPicker~iphone5" bundle:nil];
        [colorPicker setInitialColor:[WDColor redColor]];
        [self presentViewController:colorPicker animated:YES completion:nil];

    }
}

- (NSArray *)toolbarItems
{
    //设置toolbar
    UIBarButtonItem *newOne = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"new"] style:UIBarButtonItemStylePlain target:self action:@selector(createNewOne:)];
    UIBarButtonItem *foldItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(fold:)];
    UIBarButtonItem *undo = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"undo"] style:UIBarButtonItemStylePlain target:self action:@selector(undo)];
    UIBarButtonItem *redo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"redo"] style:UIBarButtonItemStylePlain target:self action:@selector(redo)];
    UIBarButtonItem *cutItem =[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *decorateItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(decorate:)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    return  @[newOne,spaceItem,
                          foldItem,spaceItem,
                          undo,spaceItem,
                          redo,spaceItem,
                          cutItem,spaceItem,
                          decorateItem];
}

//- (void)showInterface
//{
//    // 只有在工具栏隐藏的情况下才隐藏bars
////    if (self.paperToolBar.hidden)
////    {
////        [self.navigationController setNavigationBarHidden:NO animated:YES];
////        //[self.navigationController setToolbarHidden:NO animated:YES];
////    }
//
//    [self.paperToolBar showToolBar:YES fromToolBar:self.navigationController.toolbar];
//}
//
//- (void)hideInterface
//{
//    //1 .如果工具栏显示，就隐藏工具栏
////    if (self.paperToolBar.hidden)
////    {
////        [self.navigationController setNavigationBarHidden:YES animated:YES];
////       // [self.navigationController setToolbarHidden:YES animated:YES];
////    }
////    else
////    {
//        [self.paperToolBar hideToolBar:YES fromToolBar:self.navigationController.toolbar];
//  //  }
//}
//
//- (void)changeInterface:(UITapGestureRecognizer *)guesture
//{
//    if (self.navigationController.navigationBarHidden)
//    {
//        [self showInterface];
//    }
//    else
//    {
//        [self hideInterface];
//    }
//}

#pragma mark ToolBar Selector
- (void)createNewOne:(UIBarButtonItem *)barItem
{
    //[self.paperToolBar showToolBar:YES fromToolBar:self.navigationController.toolbar];
}


- (void)fold:(UIBarButtonItem *)barItem
{
    self.currentType = PaperToolTypeFold;
    NSArray *items = @[@"gear",@"new",@"add",@"add"];
    self.paperToolBar.items = items;
    [self.paperToolBar showToolBar:YES fromToolBar:self.navigationController.toolbar];
}
- (void)undo
{
    
}

- (void)redo
{
    
}

- (void)decorate:(UIBarButtonItem *)barItem
{
    self.currentType = PaperToolTypeDecorate;
    NSArray *items = @[@"add",@"add",@"add",@"add",@"add",@"add",@"add",@"add"];
    self.paperToolBar.items = items;
    [self.paperToolBar showToolBar:YES fromToolBar:self.navigationController.toolbar];
}


#pragma mark - PaperToolBarDelegate
- (void)paperToolBarItemDidSelected:(NSIndexPath *)indexPath
{
    
}
@end

