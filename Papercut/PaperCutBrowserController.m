//
//  PaperCutBrowserController.m
//  Papercut
//
//  Created by jackie on 15/1/30.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "PaperCutBrowserController.h"
#import "PaperCutLearnCell.h"
#import "LineLayout.h"
#import "UIDeviceHardware.h"

@interface PaperCutBrowserController()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PaperCutBrowserController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    LineLayout *layout = [LineLayout new];
    [self.collectionView setCollectionViewLayout:layout];
}
#pragma mark  - setup
- (void)setUp
{
    self.collectionView.backgroundColor = [UIColor clearColor];
//    LineLayout *layout = [LineLayout new];
//    [self.collectionView setCollectionViewLayout:layout];
   // [self.collectionView registerClass:[PaperCutLearnCell class] forCellWithReuseIdentifier:@"cellId"];
//    NSBundle *mainBundle = [NSBundle mainBundle];
//    UINib *nib = [UINib nibWithNibName:@"learnCell" bundle:mainBundle];
//    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"learnCell"];
    

}


#pragma mark UICollectionViewController DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PaperCutLearnCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"learnCell" forIndexPath:indexPath];
    //[cell setBackgroundColor:[UIColor blueColor]];
    return cell;
}

#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select item here");
}
@end
