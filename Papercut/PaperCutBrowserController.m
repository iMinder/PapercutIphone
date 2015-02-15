//
//  PaperCutBrowserController.m
//  Papercut
//
//  Created by jackie on 15/1/30.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "PaperCutBrowserController.h"
#import "PaperCutLearnCell.h"
#import "UIDeviceHardware.h"
#import "HeaderView.h"
#import "UIImageView+WebCache.h"

#define iPhone6 @"iPhone7,2"
#define iPhone6Plus @"iPhone7,1"

@interface PaperCutBrowserController()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSArray *items;

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

#pragma mark  - setup
- (void)setUp
{
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.version = [UIDeviceHardware platform];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    [layout setSectionInset:[self Inset]];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Learn" ofType:@"plist"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        self.items = [NSArray arrayWithContentsOfFile:path];
    }
}

- (UIEdgeInsets)Inset
{
    if ([_version isEqualToString:iPhone6])
    {
        //显示两排
        return UIEdgeInsetsMake(15, 30, 15, 30);
    }
    if ([_version isEqualToString:iPhone6Plus]) {
        //显示三排
        return UIEdgeInsetsMake(15, 10, 15, 10);
    }
    //显示两排
    return UIEdgeInsetsMake(15,15,15,15);
}

#pragma mark UICollectionViewController DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.items count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *dic = [self.items objectAtIndex:section];
    NSArray *arr = [dic valueForKey:[dic allKeys][0]];
    return [arr count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    HeaderView  *view = (HeaderView *)[self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:@"headerId" forIndexPath:indexPath];
    if ([[self.items objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = self.items[indexPath.row];
        view.title.text = [[dic allKeys] firstObject];
    }
    return  view;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PaperCutLearnCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"learnCell" forIndexPath:indexPath];
    
    if ([[self.items objectAtIndex:indexPath.section] isKindOfClass:[NSDictionary class]])
    {
     
        NSDictionary *dic = self.items[indexPath.section];
        if ([dic[[dic allKeys][0]] isKindOfClass:[NSArray class]]) {
            NSArray *arr = dic[[dic allKeys][0]];
            NSDictionary *item = arr[indexPath.row];
           // cell.title.text = item[@"title"];
            NSURL *imgURL = [NSURL URLWithString:item[@"thumbnail"]];
            [cell.thumbnail sd_setImageWithURL:imgURL placeholderImage:[UIImage imageNamed:@"main_works_off"]];
        }
    }
    return cell;
}

#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select item here");
}
@end
