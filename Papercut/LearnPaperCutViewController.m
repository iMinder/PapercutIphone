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
#import "ToolCell.h"

static const NSUInteger    kPaperDefaultBarHeight = 200;
//static const NSUInteger    kLandsdcapePhoneBarHeight = 32;
//static const float         kBarItemShadowOpacity = 0.9f;
static const NSTimeInterval kPaperAnimatedDuration = 0.3;
static const NSUInteger    kToolItemSize = 30;

typedef enum : NSUInteger {
    PaperToolTypeNone,
    PaperToolTypeFold,
    PaperToolTypeDecorate,
} PaperToolType;

@interface LearnPaperCutViewController ()<UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic)BOOL isColorSet;
@property (nonatomic)PaperToolBar *paperToolBar;
@property (nonatomic)PaperToolType currentType;
@property (nonatomic, strong) UICollectionView *toolView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation LearnPaperCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self configureGuestures];
    
    self.currentType = PaperToolTypeNone;
    NSArray *items = @[@"add",@"add",@"add",@"add",@"add",@"add",@"add",@"add"];
    self.items = items;
    
   [self setUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:NO];
    [super viewWillAppear:animated];
}

- (void)setUp {

    
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
//    flowLayout.itemSize = CGSizeMake(kToolItemSize, kToolItemSize);
//    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
//    flowLayout.minimumLineSpacing = 44;
//    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    
//    CGRect frame = CGRectMake(0, self.navigationController.toolbar.frame.origin.y, SCREEN_WIDTH, kPaperDefaultBarHeight);
//    self.toolView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
//    self.toolView.backgroundColor = [UIColor redColor];
//    NSArray *items = @[@"add",@"add",@"add",@"add",@"add",@"add",@"add",@"add"];
//    self.items = items;
//    
//    self.toolView.dataSource = self;
//    self.toolView.delegate = self;
//  
//    self.toolView.hidden = YES;
//    
//    [self.toolView registerClass:[ToolCell class] forCellWithReuseIdentifier:@"my_cell"];
//    [self.view insertSubview:self.toolView belowSubview:self.navigationController.toolbar];
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 44, SCREEN_WIDTH)];
    table.dataSource = self;
    table.delegate = self;
    
    table.backgroundColor = [UIColor redColor];
    table.transform = CGAffineTransformRotate(table.transform, - M_PI_2);
    table.center = CGPointMake(self.view.center.x, table.center.y);
    [self.view addSubview:table];
    [table registerClass:[ToolCell class] forCellReuseIdentifier:@"my_cell"];
    
    
}

#pragma mark UITableView method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToolCell *cell = [tableView dequeueReusableCellWithIdentifier:@"my_cell"];
    [cell.imageView setImage:[UIImage imageNamed:@"stylus_selected"]];
    return cell;
    
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
    self.items  = items;
    [self.toolView reloadData];
    [self showToolBar:YES fromToolBar:self.navigationController.toolbar];
    
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
    self.items = items;
    [self showToolBar:YES fromToolBar:self.navigationController.toolbar];
}

#pragma mark UICollectionViewController Delegate

//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return  [self.items count];
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ToolCell *cell = [self.toolView dequeueReusableCellWithReuseIdentifier:@"my_cell" forIndexPath:indexPath];
//    [cell.imageView setImage:[UIImage imageNamed:self.items[indexPath.row]]];
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"select item at indext %d",indexPath.row);
//}
//
#pragma mark - ToolView interface change

- (void)hideToolBar:(BOOL)animated fromToolBar:(UIToolbar *)tb
{
    
    if (!self.toolView.hidden)
    {
        tb.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:kPaperAnimatedDuration animations:^{
            self.toolView.center = CGPointMake(self.toolView.center.x, self.toolView.center.y + kPaperDefaultBarHeight);
        } completion:^(BOOL finished) {
            self.toolView.hidden = YES;
            tb.userInteractionEnabled = YES;
            self.view.userInteractionEnabled = YES;
        }];
    }
    
}

- (void)showToolBar:(BOOL)animated fromToolBar:(UIToolbar *)tb
{
    if (self.toolView.hidden)
    {
        tb.userInteractionEnabled = NO;
        self.view.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:kPaperAnimatedDuration animations:^{
            self.toolView.center = CGPointMake(self.toolView.center.x, self.toolView.center.y - kPaperDefaultBarHeight);
        } completion:^(BOOL finished) {
            tb.userInteractionEnabled = YES;
            self.view.userInteractionEnabled = YES;
            self.toolView.hidden = NO;
        }];
    }
    else
    {
        [self hideToolBar:YES fromToolBar:tb];
    }
    
}

@end

