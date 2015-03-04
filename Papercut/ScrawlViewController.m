//
//  ScrawlViewController.m
//  Papercut
//
//  Created by jackie on 15/2/16.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "ScrawlViewController.h"
#import "WDPaintingManager.h"
#import "WDThumbnailView.h"
#import "WDGridView.h"
#import "WDBlockingView.h"
#import "PaperCutAppDelegate.h"
#import "WDCanvasController.h"
#import "WDDocument.h"
#import "WDActiveState.h"
#import "MobClick.h"

@interface ScrawlViewController ()<WDGridViewDataSource,UIScrollViewDelegate, WDThumbnailViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) WDGridView *gridView;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@property (nonatomic, strong) NSMutableSet *selectedPaintings;
@property (nonatomic, strong) UIBarButtonItem *doneItem;

@end

@implementation ScrawlViewController
@synthesize gridView;
@synthesize deleteItem = deleteItem_;
@synthesize doneItem = doneItem_;
@synthesize selectedPaintings = selectedPaintings_;

- (void)awakeFromNib
{
    [super awakeFromNib];
    selectedPaintings_ = [NSMutableSet new];
    [self buildDefaultNavBar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paintingsDeleted:)
                                                 name:WDPaintingsDeleted
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paintingStartedSaving:)
                                                 name:WDDocumentStartedSavingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paintingFinishedSaving:)
                                                 name:WDDocumentFinishedSavingNotification
                                               object:nil];
}

- (void) paintingStartedSaving:(NSNotification *)aNotification
{
    if (!savingPaintings) {
        savingPaintings = [NSMutableSet set];
    }
    WDDocument *doc = (WDDocument *)aNotification.object;
    NSArray *paintings = [[WDPaintingManager sharedInstance] paintingNames];
    WDThumbnailView *thumbview = (WDThumbnailView *) [gridView visibleCellForIndex:[paintings indexOfObject:doc.displayName]];
    [savingPaintings addObject:doc.displayName];
    [thumbview startActivity];
}

- (void) paintingFinishedSaving:(NSNotification *)aNotification
{
    WDDocument *doc = (WDDocument *)aNotification.object;
    NSArray *paintings = [[WDPaintingManager sharedInstance] paintingNames];
    WDThumbnailView *thumbview = (WDThumbnailView *) [gridView visibleCellForIndex:[paintings indexOfObject:doc.displayName]];
    [thumbview updateThumbnail:doc.thumbnail];
    [savingPaintings removeObject:doc.displayName];
    [thumbview stopActivity];
}

- (void)buildDefaultNavBar
{

        [self updateTitle];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"Select")
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(startEditing:)];
  
        self.navigationItem.rightBarButtonItems = @[rightItem];
}

- (void)buildEditNavBar
{
    [self updateTitle];
    
    if (!deleteItem_) {
        deleteItem_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                    target:self
                                                                    action:@selector(showDeleteMenu:)];
    }
    if (!doneItem_) {
        doneItem_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                  target:self
                                                                  action:@selector(stopEditing:)];
    }
    self.navigationItem.rightBarButtonItems = @[doneItem_, deleteItem_];
    
    
}

- (void) dismissPopoverAnimated:(BOOL)animated
{
    if (deleteSheet_) {
        [deleteSheet_ dismissWithClickedButtonIndex:deleteSheet_.cancelButtonIndex animated:NO];
        deleteSheet_ = nil;
    }
}
- (void)showDeleteMenu:(id)sender
{
    if (deleteSheet_) {
        [self dismissPopoverAnimated:NO];
        return;
    }
    [self dismissPopoverAnimated:NO];
    
    NSString *format = NSLocalizedString(@"Delete %d Paintings", @"Delete %d Paintings");
    NSString *action = (selectedPaintings_.count) == 1 ? NSLocalizedString(@"Delete Painting", @"Delete Painting") :
    [NSString stringWithFormat:format, selectedPaintings_.count];
    
    deleteSheet_ = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    deleteSheet_.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    deleteSheet_.destructiveButtonIndex = [deleteSheet_ addButtonWithTitle:action];
    deleteSheet_.cancelButtonIndex = [deleteSheet_ addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
    
    [deleteSheet_ showFromBarButtonItem:sender animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == deleteSheet_) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self deleteSelectedPaintings];
        }
    }
    
    deleteSheet_ = nil;
}

- (void) deleteSelectedPaintings
{
    NSString *format = NSLocalizedString(@"Delete %d Paintings", @"Delete %d Paintings");
    NSString *title = (selectedPaintings_.count) == 1 ? NSLocalizedString(@"Delete Painting", @"Delete Painting") :
    [NSString stringWithFormat:format, selectedPaintings_.count];
    
    NSString *message;
    
    if (selectedPaintings_.count == 1) {
        message = NSLocalizedString(@"Once deleted, this painting cannot be recovered.", @"Alert text when deleting 1 painting");
    } else {
        message = NSLocalizedString(@"Once deleted, these paintings cannot be recovered.", @"Alert text when deleting multiple paintings");
    }
    
    NSString *deleteButtonTitle = NSLocalizedString(@"Delete", @"Title of Delete button");
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Title of Cancel button");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:deleteButtonTitle, cancelButtonTitle, nil];
    alertView.cancelButtonIndex = 1;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    [[WDPaintingManager sharedInstance] deletePaintings:selectedPaintings_];
    
    [self updateTitle];
}

- (void)properlyEnableNavBarItems
{
    deleteItem_.enabled = selectedPaintings_.count > 0 ? YES : NO;
}

- (void)startEditing:(id)sender
{
    [self setEditing:YES animated:YES];
}

- (void)stopEditing:(id)sender
{
    [self setEditing:NO animated:YES];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self buildEditNavBar];
        [self properlyEnableNavBarItems];
    }else{
        for (WDThumbnailView *thumbview in gridView.visibleCells) {
            thumbview.selected = NO;
        }
        
        [selectedPaintings_ removeAllObjects];
        
        [self buildDefaultNavBar];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)updateTitle
{
    if (self.isEditing) {
        NSString *format = NSLocalizedString(@"%d Selected", @"%d Selected");
        self.title = [NSString stringWithFormat:format, selectedPaintings_.count];
    }else
    {
        NSInteger count = [[WDPaintingManager sharedInstance] numberOfPaintings];
        NSString *format = NSLocalizedString(@"Gallery: %d", @"Gallery: %d");
        self.title = [NSString stringWithFormat:format, count];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [WDActiveState sharedInstance];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    NSUInteger currentCenteredIndex = [gridView approximateIndexOfCenter];
    if (centeredIndex != 0 && centeredIndex != currentCenteredIndex) {
        [self.gridView centerIndex:centeredIndex];
    }
    
    [MobClick beginLogPageView:@"我的作品"];
    [MobClick endEvent:@"MainPage_4"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    centeredIndex = [gridView approximateIndexOfCenter];
    [MobClick endLogPageView:@"我的作品"];
}


- (void)setUp
{
    [self.navigationController setNavigationBarHidden:NO];
    
    CGRect frame = CGRectMake(0, 64, SCREEN_WIDTH , SCREEN_HEIGHT - 64);
    gridView = [[WDGridView alloc] initWithFrame:frame];
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    gridView.backgroundColor = [UIColor clearColor];
    gridView.delegate = self;
    gridView.alwaysBounceVertical = YES;
    gridView.dataSource = self;
    [gridView registerClass:[WDThumbnailView class] forCellWithReuseIdentifier:@"thumbnail"];
    
    [self.view addSubview:gridView];
   // [gridView scrollToBottom];
}
#pragma mark WDGridView
- (NSInteger) cellDimension
{
    return  90 ; // 148 for big thumbs on the iPhone
}

#pragma mark - WDGridView DataSource Method
- (NSUInteger)numberOfItemsInGridView:(WDGridView *)inGridView
{
    return [[WDPaintingManager sharedInstance] numberOfPaintings];
}

- (UIView *) gridView:(WDGridView *)inGridView cellForIndex:(NSUInteger)index
{
    WDThumbnailView *thumbview = [inGridView dequeueReusableCellWithReuseIdentifier:@"thumbnail" forIndex:index];
    
    NSArray *paintings = [[WDPaintingManager sharedInstance] paintingNames];
    
    thumbview.target = self;
    thumbview.delegate = self;
    thumbview.filename = paintings[index];
    thumbview.tag = index;
    thumbview.action = @selector(tappedOnPainting:);
    // selectedPaintings_ should be empty if we're not editing
    [savingPaintings containsObject:thumbview.filename] ? [thumbview startActivity] : [thumbview stopActivity];
    thumbview.selected = [selectedPaintings_ containsObject:thumbview.filename] ? YES : NO;
    
    return thumbview;
}

- (void)tappedOnPainting:(id)sender
{
    if (editingThumbnail_) {
        return;
    }
    
    if (!self.isEditing) {
        NSUInteger index = [(UIView *)sender tag];
        //返回一个对应的Document对象
        WDDocument *document = [[WDPaintingManager sharedInstance] paintingAtIndex:index];
        [self openDocument:document editing:NO];
        
    }else{
        WDThumbnailView     *thumbnail = (WDThumbnailView *)sender;
        NSString            *filename = [[WDPaintingManager sharedInstance] fileAtIndex:[thumbnail tag]];
        
        if ([selectedPaintings_ containsObject:filename]) {
            thumbnail.selected = NO;
            [selectedPaintings_ removeObject:filename];
        } else {
            thumbnail.selected = YES;
            [selectedPaintings_ addObject:filename];
        }
        
        [self updateTitle];
        
        [self properlyEnableNavBarItems];
    }
}


- (void) paintingsDeleted:(NSNotification *)aNotification
{
    NSSet *deletedNames = aNotification.object;
    NSArray *paintings = [[WDPaintingManager sharedInstance] paintingNames];
    for (NSString *name in deletedNames) {
        WDThumbnailView *thumbview = (WDThumbnailView *) [gridView visibleCellForIndex:[paintings indexOfObject:name]];
        [thumbview clear];
    }
    
    // do after thumbnails are cleared or they shuffle around
    [selectedPaintings_ removeAllObjects];
    
    [gridView cellsDeleted];
    [self updateTitle];
    
    [self properlyEnableNavBarItems];
}

#pragma mark - WDThumbnailDelegate

- (BOOL) thumbnailShouldBeginEditing:(WDThumbnailView *)thumb
{
    if (self.isEditing) {
        return NO;
    }
    
    return editingThumbnail_ ? NO : YES;
    
}
- (void) thumbnailDidBeginEditing:(WDThumbnailView *)thumb
{
    editingThumbnail_ = thumb;
}

- (void) thumbnailDidEndEditing:(WDThumbnailView *)thumb
{
    [UIView animateWithDuration:0.2f
                     animations:^{ blockingView_.alpha = 0; }
                     completion:^(BOOL finished) {
                         [blockingView_ removeFromSuperview];
                         blockingView_ = nil;
                     }];
    
    editingThumbnail_ = nil;
}

- (void) blockingViewTapped:(id)sender
{
    [editingThumbnail_ stopEditing];
}

- (void) didEnterBackground:(NSNotification *)aNotification
{
    if (!editingThumbnail_) {
        return;
    }
    
    [editingThumbnail_ stopEditing];
}

- (void) keyboardWillShow:(NSNotification *)aNotification
{
    if (!editingThumbnail_ || blockingView_) {
        return;
    }
    
    NSValue     *endFrame = [aNotification userInfo][UIKeyboardFrameEndUserInfoKey];
    CGRect      frame = [endFrame CGRectValue];
    float       delta = 0;
    
    CGRect thumbFrame = editingThumbnail_.frame;
    thumbFrame.size.height += 20; // add a little extra margin between the thumb and the keyboard
    frame = [gridView convertRect:frame fromView:nil];
    
    if (CGRectIntersectsRect(thumbFrame, frame)) {
        delta = CGRectGetMaxY(thumbFrame) - CGRectGetMinY(frame);
        
        CGPoint offset = gridView.contentOffset;
        offset.y += delta;
        [gridView setContentOffset:offset animated:YES];
    }
    
    blockingView_ = [[WDBlockingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    PaperCutAppDelegate *delegate =  [UIApplication sharedApplication].delegate;
    
    blockingView_.passthroughViews = @[editingThumbnail_.titleField];
    [delegate.window addSubview:blockingView_];
    
    blockingView_.target = self;
    blockingView_.action = @selector(blockingViewTapped:);
}

#pragma mark - Show

- (void) openDocument:(WDDocument *)document editing:(BOOL)editing
{
    WDCanvasController *canvasController = [[WDCanvasController alloc] init];
    [self.navigationController pushViewController:canvasController animated:YES];
    // set the document before setting the editing flag
    canvasController.document = document;
    
    //在主线程调用这个方法来处理打开后的操作
    [document openWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                canvasController.editing = editing || ([document.history count] <= 4);
            } else {
                [self showOpenFailure:document];
            }
        });
    }];
}

- (void) showOpenFailure:(WDDocument *)document
{
    NSString *title = NSLocalizedString(@"Could Not Open Painting", @"Could Not Open Painting");
    NSString *format = NSLocalizedString(@"There was a problem opening “%@”.", @"There was a problem opening “%@”.");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:[NSString stringWithFormat:format, document.displayName]
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
