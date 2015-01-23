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

@interface LearnPaperCutViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic)BOOL isColorSet;
@end

@implementation LearnPaperCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self configureGuestures];
    [self showInterface];
    self.navigationController.hidesBarsOnTap = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (void)showInterface
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    //设置toolbar
    UIBarButtonItem *newOne = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"new"] style:UIBarButtonItemStylePlain target:self action:@selector(createNewOne:)];
    UIBarButtonItem *foldItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *undo = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"undo"] style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
    UIBarButtonItem *redo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"redo"] style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
    UIBarButtonItem *cutItem =[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *decorateItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:nil];

    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[newOne,spaceItem,
                          foldItem,spaceItem,
                          undo,spaceItem,
                          redo,spaceItem,
                          cutItem,spaceItem,
                          decorateItem];
    
}

#pragma mark ToolBar Selector
- (void)createNewOne:(UIBarButtonItem *)barItem
{
    
}

- (void)hideInterface
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)changeInterface:(UITapGestureRecognizer *)guesture
{
    if (self.navigationController.navigationBarHidden)
    {
        [self showInterface];
    }
    else
    {
        [self hideInterface];
    }
}

//- (void)configureGuestures
//{
//    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeInterface:)];
//    oneTap.delegate = self;
//    oneTap.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:oneTap];
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showColorPicker];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
