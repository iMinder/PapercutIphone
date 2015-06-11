//
//  LearnPapercutViewController.m
//  Papercut
//
//  Created by jackie on 15/3/6.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "LearnPapercutViewController.h"
#import "PapercutCanvas.h"
#import "WDLabel.h"
#import "WDUtilities.h"
#import "UIView+Additions.h"
#import "PaintView.h"
#import "WDColorPickerController.h"
#import "WDActiveState.h"
#import "WDPaintingManager.h"

#define kMessageFadeDelay           0.5
#define kMinimumMessageWidth        80
#define kMinDismension              150
#define kMaxFoldDepth               6
#define kPreviewTag                 1000

@interface LearnPapercutViewController () <PapercutCanvasAnimationDelegate, UIGestureRecognizerDelegate, WDColorChangeDidChangeProtocol ,UIAlertViewDelegate >


@property (weak, nonatomic)   IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) PapercutCanvas *canvas;
@property (weak, nonatomic)   IBOutlet UILabel *tips;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem *undo;
@property (weak, nonatomic)   IBOutlet UIBarButtonItem *redo;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;

@property (nonatomic, assign) NSArray *currentItems;
@property (nonatomic, strong) NSArray *folds;
@property (nonatomic, strong) NSArray *decorates;
@property (nonatomic, strong) NSMutableArray *redos;
@property (nonatomic, strong) NSMutableArray *undos;

@property (nonatomic, strong) NSMutableDictionary *subViews;

@end

@implementation LearnPapercutViewController
{
    WDLabel *messageLabel_;
    NSTimer *messageTimer_;
    CGFloat initialScale_;
    CGFloat previousScale_;
    
    UIImageView *decorateView_;
    UIView *workView;
    
    BOOL isPreview;
    PapercutCanvas *preview;
    NSUndoManager *undoManager;
    WDColorPickerController *colorPickerController;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (CGFloat)fitDimension
{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = self.collectionView.frame.origin.y - self.previewButton.frame.origin.y;
    
    CGFloat dismension = MIN(width, height) - 10;
    return dismension;
}

- (void)setup
{
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
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
    _subViews = [NSMutableDictionary new];
    undoManager = [NSUndoManager new];
    //[self colorPicker:nil];
    [self createNewCanvas];
}

- (UIImage *)snapshot:(UIView *)view
{
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
//    //[view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
//    [view.layer drawInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
    
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view.layer.presentationLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

- (void)done:(UIBarButtonItem *)rightBarItem
{
    if (currentOperationMode != PCOperationModePreview) {
       [self preview:self.previewButton];
    }
    
    //开始保存当前preview到作品集里面
    if (preview) {
        UIImage *image = [self snapshot:preview.currentView];
    
     //保存到UIDocument路径下
        [[WDPaintingManager sharedInstance] createNewPaintingWithImage:image];
        [self showMessage:@"保存成功"];
    }
    
    
}

- (void)configureGestures
{
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlerPinchGesture:)];
    pinchGesture.delegate  = self;
    [self.view addGestureRecognizer:pinchGesture];
}

#pragma mark - gesture handler


- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)handlerPinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGFloat scale = [gestureRecognizer scale];
        CGFloat width = CGRectGetHeight(_canvas.frame);
        if (width * scale < [self fitDimension] ) {
            _canvas.transform = CGAffineTransformScale(_canvas.transform, scale, scale);
        }
    }
    [gestureRecognizer setScale:1.0];
}

- (void)handlerPangesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (currentOperationMode == PCOperationModeCaijian) {
        return;
    }
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
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
    
    return cell;
}
- (IBAction)itemTapped:(UIButton *)sender {
    CGPoint location = [sender convertPoint:sender.center toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    [self performAction:indexPath.row];
}

- (NSInteger)foldCount
{
    NSInteger count = 0;
    for (id temp in _undos){
        if ([temp isMemberOfClass:[PapercutCanvas class]]) {
            count++;
        }
    }
    return count;
}
- (void)foldViewWithType:(NSInteger)type
{
    if ([self foldCount ] > kMaxFoldDepth) {
        [self showMessage:@"折叠次数太多了"];
        return;
    }
    
    if (![_canvas PC_canTransformToType:type]) {
        [self showMessage:@"不支持这样折叠"];
        return;
    }
    
   [_canvas PC_animationWithType:type];
}

- (void)configurePanGestureFor:(id) view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlerPangesture:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    if ([view isMemberOfClass:[PapercutCanvas class]]) {
        canvasPanGesture = panGesture;
    }
}


- (void)decorateCanvas:(NSInteger) index
{
    decorateView_. userInteractionEnabled = NO;
    UIImage *image = [UIImage imageNamed:_decorates[index]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    //add gesture
    imageView.userInteractionEnabled = YES;
    [self configurePanGestureFor:imageView];
   
    //配置ImageView的位置信息
    
    [_canvas addImageView:imageView];
    decorateView_ = imageView;
    [self addUndoObject:decorateView_];
}

- (void)performAction:(NSInteger)index
{
    switch (currentOperationMode) {
        case PCOperationModeFold:
        {
            [self foldViewWithType:index];
        }
            break;
        case PCOPerationModeDecorate:
        {
            [self decorateCanvas:index];
        }
            break;
        case PCOperationModeCaijian:
            [self caijian:nil];
            break;
        default:
            break;
    }
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
    
    CGFloat dismension = [self fitDimension];
   
    if (!workView) {
        
        workView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dismension, dismension)];
        workView.backgroundColor = nil;
        workView.sharpCenter = self.view.center;
        workView.clipsToBounds = YES;
        [self.view addSubview:workView];
    }
    if (_canvas) {
        [_canvas removeFromSuperview];
        _canvas = nil;
    }
    _canvas = [[PapercutCanvas alloc] initWithFrame:CGRectMake(0, 0, dismension, dismension)];
    _canvas.delegate = self;
    [workView addSubview:_canvas];
    [self configurePanGestureFor:_canvas];
    
    [_undos removeAllObjects];
    [_redos removeAllObjects];
   
    [self configureGestures];
    //[self.view insertSubview:_canvas atIndex:[self.view.subviews count]];
    //[self.view addSubview:_canvas];
}

- (IBAction)create:(id)sender
{
    //清空
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", @"提示")
message:NSLocalizedString(@"放弃当前作品?","放弃当前作品?") delegate:self cancelButtonTitle:NSLocalizedString(@"取消", @"取消")  otherButtonTitles:NSLocalizedString(@"确认", @"确认"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self colorPicker:nil];
    }
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
    if (currentOperationMode == PCOperationModePreview) {
        [self showMessage:@"请先取消预览"];
        return;
    }
    
    self.currentItems = _decorates;
    currentOperationMode = PCOPerationModeDecorate;
    self.collectionView.hidden = NO;
    
}

#pragma mark undo redo
- (void)addUndoObject:(id)view
{
    [self.redos removeAllObjects];
    [self.undos addObject:view];
}

- (BOOL)canRedo
{
    return [self.redos count] > 0 ;
}

- (BOOL)canUndo
{
    return [self.undos count] > 0 ;
}

- (IBAction)undo:(id)sender
{
    if (PCOperationModePreview == currentOperationMode) {
        [self showMessage:@"清先取消预览"];
        return;
    }
    if ([self canUndo]) {
        //[self showMessage:@"撤销"];
        [self undo_];
    } else {
        [self showMessage:@"没有可撤销项"];
    }

}

- (void)undo_{
    //根据当前操作来决定如何进行undo和redo
    id lastView = [_undos lastObject];
    if ([lastView isMemberOfClass:[PapercutCanvas class]]) {
        //undo最后一步是一个折叠操作
        [_redos addObject:_canvas];
        [_canvas removeFromSuperview];
        _canvas = lastView;
        _canvas.hidden = NO;
        [workView addSubview:_canvas];
    } else {
        [_redos addObject:lastView];
        [lastView removeFromSuperview];
    }
    [_undos removeLastObject];
}

- (IBAction)redo:(id)sender
{
    if (currentOperationMode == PCOperationModePreview) {
        [self showMessage:@"请先取消预览"];
        return;
    }
    if ([self canRedo]) {
       // [self showMessage:@"重做"];
        [self redo_];
    } else {
        [self showMessage:@"没有可重做项"];
    }
}

- (void)redo_
{
    //根据_redos的内容来执行下一步操作
    id previous = [_redos lastObject];
    if ([previous isMemberOfClass:[PapercutCanvas class]]) {
        [_undos addObject:_canvas];
        [_canvas removeFromSuperview];
        _canvas = previous;
        [workView addSubview:_canvas];
    } else {
        [_undos addObject:previous];
       // [decorateView_ removeFromSuperview];
        //decorateView_ = previous;
        [_canvas.currentView addSubview:previous];
    }
    
    [_redos removeLastObject];
//    [_undos addObject:_canvas];
//    [_canvas removeFromSuperview];
//    _canvas = [_redos lastObject];
//    [_redos removeLastObject];
//    [workView addSubview:_canvas];
}

- (IBAction)caijian:(id)sender
{
    if (currentOperationMode == PCOperationModePreview) {
        [self showMessage:@"请先取消预览"];
        return;
    }
    currentOperationMode = PCOperationModeCaijian;
    
    PaintView *paintView = [[PaintView alloc] initWithCanvas:_canvas];
    paintView.backgroundColor  = [UIColor clearColor];
    
    [_canvas removeGestureRecognizer:canvasPanGesture];
    [_canvas.currentView addSubview:paintView];
    
    //追加通知消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(caijianDone:) name:PaintViewCaiJianDoneNotification object:nil];
}

- (void)caijianDone:(NSNotification *)notification
{
    //裁减完成
    PaintView *paintView = notification.object;
    paintView.userInteractionEnabled = NO;
    [self addUndoObject:paintView];
    //从裁减模式退出来
}
- (IBAction)colorPicker:(UIButton *)sender {
   //颜色选取器
    if (!colorPickerController) {
        colorPickerController = [[WDColorPickerController alloc]
                                 initWithNibName:@"ColorPicker~iphone5" bundle:nil];
    }
    colorPickerController.delegate = self;
    [colorPickerController setInitialColor:[WDActiveState sharedInstance].paintColor];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:colorPickerController];
    [self presentViewController:navController animated:YES completion:nil];
    
}

- (void)colorDidChange
{
    //改变当前
    [self createNewCanvas];
    
}
#pragma mark - inline call

- (CATransform3D) transformForType:(AnimationType)type
{
    CATransform3D transform = CATransform3DIdentity;
    
    switch (type) {
        case ATVertically:
            transform = CATransform3DRotate(transform, M_PI, 1.0, 0.0, 0.0);
            break;
        case ATHorizonally:
            transform = CATransform3DRotate(transform, M_PI, 0.0, 1.0, 0.0);
            break;
        case ATRightTopFoldAnimation:
            transform = CATransform3DRotate(transform, M_PI, -1.0, 1.0, 0.0);
            break;
        case ATRightBottomFoldAnimation:
            transform = CATransform3DRotate(transform, M_PI, 1.0, 1.0, 0.0);
            break;
        default:
            break;
    }
    return transform;
}

- (CATransform3D) transformForUnfold:(AnimationType)animationType
{
    CATransform3D transform = CATransform3DIdentity;
    
    switch (animationType) {
        case ATVertically:
            transform = CATransform3DRotate(transform, M_PI, 1.0, 0.0, 0.0);
            break;
        case ATHorizonally:
            transform = CATransform3DRotate(transform, M_PI, 0.0, 1.0, 0.0);
            break;
        case ATRightTopFoldAnimation:
            transform = CATransform3DRotate(transform, M_PI, 1.0, 1.0, 0.0);
            break;
        case ATRightBottomFoldAnimation:
            transform = CATransform3DRotate(transform, M_PI, 1.0, -1.0, 0.0);
            break;
        default:
            break;
    }
    return transform;
}

- (CGAffineTransform) transformWithType:(AnimationType) type
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (type) {
        case ATVertically:
            transform = CGAffineTransformMakeScale(1.0, -1.0);
            break;
        case ATHorizonally:
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            break;
        default:
            break;
    }
    return transform;
}

- (void)flipView:(UIView *)view inSuper:(PapercutCanvas *)parent
{
    if (parent.animationType == ATRightTopFoldAnimation) {
        UIView *view = [[UIView alloc] initWithFrame:parent.bounds];
        CGAffineTransform transform = [self transformWithType:ATHorizonally];
        transform = CGAffineTransformRotate(transform, M_PI);
        [parent addSubview:view];
    }
    view.transform = [self transformWithType:parent.animationType];

}

- (CGPoint)centerTo:(UIView *)view withParent:(PapercutCanvas*)parent
{
    CGPoint center = CGPointZero;
    switch (parent.animationType) {
        case ATVertically:
            center =  CGPointMake(view.center.x, CGRectGetHeight(parent.bounds) * 2 - view.center.y);
            break;
        case ATHorizonally:
            center = CGPointMake(CGRectGetWidth(parent.bounds) * 2 - view.center.x, view.center.y);
            break;
        case ATRightTopFoldAnimation:
            center = CGPointMake(view.center.y, view.center.x);
            break;
        case ATRightBottomFoldAnimation:
        {
            CGFloat width = CGRectGetWidth(view.bounds);
            center = CGPointMake(width - view.center.y, width - view.center.x);
        }
            break;
        default:
            break;
    }
    return center;
}

/**
 *  进行预览处理
 *
 *  @param sender 预览按钮
 */
- (IBAction)preview:(UIButton *)sender {
    //进行预览功能
    if (currentOperationMode != PCOperationModePreview) {
       
        
        currentOperationMode  = PCOperationModePreview;
       [sender setTitle:@"取消预览" forState:UIControlStateNormal];
        
        if ([self foldCount] == 0) {
            return ;
        }
        
        PapercutCanvas *current = _canvas;
        NSInteger depth = [_undos count] - 1;
        while (depth >= 0) {
             id temp = _undos[depth--];
            
            //不是PapercutCanvas
            if (![temp isMemberOfClass:[PapercutCanvas class]]) {
                continue;
            }
            preview = temp;
            BOOL haveSubview = NO;
            UIView *transformView = [[UIView alloc] initWithFrame:preview.bounds];
            transformView.tag = kPreviewTag;
            //思路：获取每一次的subViews,将其加入到一个temp view里，然后放到它之前的view，依次向前递推，实现最终的预览效果
            //只有存在装饰或者
            NSMutableArray *subviews = [NSMutableArray new];
            for (UIView *view in current.currentView.subviews) {
                if (view.tag == kPreviewTag) {
                    haveSubview = YES;
                    [transformView addSubview:view];
                } else if ([view isKindOfClass:[UIImageView class]]) {
                    haveSubview = YES;
                    [subviews addObject:view];
                    [transformView addSubview:view];
                } else if( [view isMemberOfClass:[PaintView class]]) {
                    haveSubview = YES;
                    [subviews addObject:view];
                    [transformView addSubview:view];
                }
            }
            [_subViews setObject:subviews forKey:current.UUID];
            if (haveSubview){
                UIView *copyTransform = [transformView snapshotViewAfterScreenUpdates:YES];
                copyTransform.tag = kPreviewTag;
                copyTransform.layer.transform = [self transformForUnfold:preview.animationType];
                [preview.currentView addSubview:transformView];
                [preview.currentView addSubview:copyTransform];
            }
            current = preview;
        }
        //先移除_canvas
        [_canvas removeFromSuperview];
        UIView *view = preview.currentView;
        
        [workView addSubview:preview];
        
    } else {
        currentOperationMode = PCOperationModeNone;
        [sender setTitle:@"预览" forState:UIControlStateNormal];
        //移除预览多加载的那些项;
        for ( id temp in _undos) {
            if (![temp isMemberOfClass:[PapercutCanvas class]]) {
                continue;
            }
            PapercutCanvas *canvas = temp;
            for (UIView *added in canvas.currentView.subviews) {
                if (added.tag == kPreviewTag) {
                    [added removeFromSuperview];
                }
            }
            //将每一个view的subview，因为上述删除掉了，重新放置回去
            NSArray *subviews = [_subViews objectForKey:canvas.UUID];
            if (subviews) {
                for (UIView *view in subviews) {
                    [canvas.currentView addSubview:view];
                }
            }
        }
       
        NSArray *subviews = [_subViews objectForKey:_canvas.UUID];
        if (subviews) {
            for (UIView *view in subviews) {
                [_canvas.currentView addSubview:view];
            }
        }
        
        [_subViews removeAllObjects];
        //可能存在当前页就是预览页
        if (preview != _canvas) {
            [preview removeFromSuperview];
            [workView addSubview:_canvas];
        }
    }

}

#pragma mark - PapercutCanvasAnimationDelegate

- (void)animationDidStart
{
    
}

- (void)animationDidStop:(PapercutCanvas *)newCanvas
{
    [self addUndoObject:_canvas];
    [_canvas removeFromSuperview];
    [_canvas.layer setMask:nil];
    [workView addSubview:newCanvas];
   // [self.view insertSubview:newCanvas atIndex:[self.view.subviews count]];
    newCanvas.delegate = self;
    _canvas = newCanvas;
    [self configurePanGestureFor:_canvas];
}


#pragma mark - show message
- (void) showMessage:(NSString *)message
{
    [self showMessage:message autoHide:YES position:WDCenterOfRect(self.view.bounds) duration:kMessageFadeDelay];
}

- (void) showMessage:(NSString *)message autoHide:(BOOL)autoHide position:(CGPoint)position duration:(float)duration
{
    BOOL created = NO;
    
    if (!messageLabel_) {
        messageLabel_ = [[WDLabel alloc] initWithFrame:CGRectInset(CGRectMake(0,0,100,40), -8, -8)];
        messageLabel_.textColor = [UIColor whiteColor];
        messageLabel_.font = [UIFont boldSystemFontOfSize:24.0f];
        messageLabel_.textAlignment = NSTextAlignmentCenter;
        messageLabel_.opaque = NO;
        messageLabel_.backgroundColor = nil;
        messageLabel_.alpha = 0;
        
        created = YES;
    }
    
    if ([message length] > 20 ) {
        messageLabel_.font = [UIFont boldSystemFontOfSize:15.0f];
    } else {
        messageLabel_.font = [UIFont boldSystemFontOfSize:24.0f];
    }
    
    messageLabel_.text = message;
    [messageLabel_ sizeToFit];
    
    CGRect frame = messageLabel_.frame;
    frame.size.width = MAX(frame.size.width, kMinimumMessageWidth);
    frame = CGRectInset(frame, -20, -15);
    messageLabel_.frame = frame;
    messageLabel_.sharpCenter = position;
    
    if (created) {
        [self.view addSubview:messageLabel_];
        
        [UIView animateWithDuration:0.2f animations:^{ messageLabel_.alpha = 1; }];
    }
    
    // start message dismissal timer
    if (messageTimer_) {
        [messageTimer_ invalidate];
        messageTimer_ = nil;
    }
    
    if (autoHide) {
        messageTimer_ = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(hideMessage:) userInfo:nil repeats:NO];
    }
}

- (void) nixMessageLabel
{
    if (messageTimer_) {
        [messageTimer_ invalidate];
        messageTimer_ = nil;
    }
    
    if (messageLabel_) {
        [messageLabel_ removeFromSuperview];
        messageLabel_ = nil;
    }
}

- (void)hideMessage:(NSTimer *)timer
{
    [UIView animateWithDuration:0.2f
                     animations:^{ messageLabel_.alpha = 0.0f; }
                     completion:^(BOOL finished) {
                         [self nixMessageLabel];
                     }];
    
}

@end
