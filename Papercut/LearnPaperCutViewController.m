//
//  LearnPapercutViewController.m
//  Papercut
//
//  Created by jackie on 15/3/6.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "LearnPapercutViewController.h"
#import "PapercutCanvas.h"
#import "UIView+Animation.h"

@interface LearnPapercutViewController ()

@property (weak, nonatomic)   IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIView *canvas;
@property (weak, nonatomic)   IBOutlet UILabel *tips;
@property (weak, nonatomic)   IBOutlet UIButton *preview;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem *undo;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem *redo;

@property (nonatomic, assign) NSArray *currentItems;
@property (nonatomic, strong) NSArray *folds;
@property (nonatomic, strong) NSArray *decorates;
@property (nonatomic, strong) NSMutableArray *redos;
@property (nonatomic, strong) NSMutableArray *undos;

@end

@implementation LearnPapercutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)setup
{
    _folds = @[@"fold_1" ,
                @"fold_2",
                @"fold_3" ,
               @"fold_4" ];
    
    NSMutableArray *items = [NSMutableArray new];
    
    for (int i = 1; i < 24 ; i++) {
        NSString *name = [NSString stringWithFormat:@"ele%d_on", i];
        [items addObject:name];
    }
    self.decorates = items;
    self.currentItems = _decorates;
    _undos = [NSMutableArray new];
    _redos = [NSMutableArray new];
    [self createNewCanvas];
}

- (void)setCurrentItems:(NSArray *)currentItems
{
    if (_currentItems == currentItems) {
        return;
    }
    _currentItems = currentItems;
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark UIColloctionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.currentItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell_ID" forIndexPath:indexPath];
    UIButton *item = (UIButton *)[cell.contentView viewWithTag:10];
    [item setBackgroundImage:[UIImage imageNamed:_currentItems[indexPath.row]] forState:UIControlStateNormal];
    
//    UIImageView *imageview = (UIImageView*)[cell.contentView viewWithTag:10];
//    [imageview setImage:[UIImage imageNamed:_currentItems[indexPath.row]]];
    
    return cell;
}
- (IBAction)itemTapped:(UIButton *)sender {
    CGPoint location = [sender convertPoint:sender.center toView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    //[self interfaceChange];
    //NSLog(@"select item at index %d", indexPath.row);
    [self performAction:indexPath.row];
}


- (void)performAction:(NSInteger)index
{
    switch (currentOperationMode) {
        case PCOperationModeFold:
        {
            [self foldViewWithType:index];
        }
            break;
            
        default:
            break;
    }
}

- (void)foldViewWithType:(NSInteger)type
{
    [_canvas animationWithType:type];
    //执行各种折叠动作
//    [[FlipAnimationManager sharedInstance] startAnimation:_canvas Type:type Descending:NO Completion:^(BOOL finished, UIView *flipView, CALayer *layer) {
//        //折叠完成，只显示折叠后的部分
//        
////        _canvas = [[PapercutCanvas alloc] initWithFrame:flipView.frame];
////        _canvas.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_fill"]];
////        [_undos addObject:flipView];
////        [flipView removeFromSuperview];
////        [_canvas.layer addSublayer:layer];
////        [self.view addSubview:_canvas];
//    }];
    
}

- (void)animationDidStart:(CAAnimation *)anim
{
    NSLog(@"did start");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"did end");
}


#pragma mark - interface change
- (void)undoStatusDidChange:(id)sender
{
    _undo.enabled = [self canUndo];
    _redo.enabled = [self canRedo];
}
- (IBAction)tapped:(UITapGestureRecognizer *)sender
{
    [self interfaceChange];
}
- (void)interfaceChange
{
    self.collectionView.hidden = !self.collectionView.hidden;
}

#pragma mark - Operation

- (void)createNewCanvas
{
    //绘制canvas
    CGFloat width = SCREEN_WIDTH;
    CGFloat height = self.collectionView.frame.origin.y - self.preview.frame.origin.y;
    
    CGFloat dismention = MIN(width, height) - 10;
    
    _canvas = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dismention, dismention)];//[[PapercutCanvas alloc] initWithFrame:CGRectMake(0, 0, dismention, dismention)];
    //_canvas.backgroundColor = [UIColor redColor];

    _canvas.center = self.view.center;
    [self.view insertSubview:_canvas atIndex:[self.view.subviews count]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"styleLandscape"]];
    [_canvas addSubview:imageView];
    
    
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ele3_on"]];
//    imageView.center = _canvas.center;
//    [_canvas addSubview:imageView];

    _canvas.backgroundColor = [UIColor redColor];
//    CGFloat wid = CGRectGetWidth(_canvas.bounds);
//    CGFloat heig = CGRectGetHeight(_canvas.bounds);
//    UIBezierPath *path = [UIBezierPath new];
//    [path moveToPoint:POINT(0, 0)];
//    [path addLineToPoint:POINT(wid, 0)];
//    [path addLineToPoint:POINT(0, heig)];
//    [path closePath];
//    _canvas.fillColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_fill"]];
//    //_canvas.strokeColor = [UIColor greenColor];
//    _canvas.path = path;
   //_canvas.path = [UIBezierPath bezierPathWithRect:_canvas.bounds];
   // _canvas.fillColor = [UIColor redColor];
    
}

- (IBAction)create:(id)sender
{
    //清空
    
}

- (IBAction)fold:(id)sender
{
    //[self interfaceChange];
    self.currentItems = _folds;
    
    currentOperationMode = PCOperationModeFold;
    self.collectionView.hidden = NO;
}

- (IBAction)decorate:(id)sender
{
    //[self interfaceChange];
    self.currentItems = _decorates;
    currentOperationMode = PCOPerationModeDecorate;
    self.collectionView.hidden = NO;
    
}

- (BOOL)canRedo
{
    return [self.redos count] > 0;
}

- (BOOL)canUndo
{
    return [self.undos count] > 0;
}

- (IBAction)undo:(id)sender
{
    if ([self canUndo])
    {
        [self undo_];
    }
}

- (void)undo_{
    [_redos addObject:_canvas];
    [_canvas removeFromSuperview];
    _canvas = [_undos lastObject];
    _canvas.hidden = NO;
    [_undos removeLastObject];
    [self.view addSubview:_canvas];
}
- (IBAction)redo:(id)sender
{
    if ([self canRedo])
    {
        [self redo_];
    }
}
- (void)redo_
{
    [_undos addObject:_canvas];
    [_canvas removeFromSuperview];
    _canvas = [_redos lastObject];
    [_redos removeLastObject];
    [self.view addSubview:_canvas];
}
- (IBAction)caijian:(id)sender
{
    currentOperationMode = PCOperationModeCaijian;
    
}
- (IBAction)colorPicker:(UIButton *)sender {
    
}

- (IBAction)preview:(UIButton *)sender {
}

@end
