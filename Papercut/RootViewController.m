//
//  ViewController.m
//  Papercut
//
//  Created by jackie on 14-5-25.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "RootViewController.h"
#import "SoundServiceManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SVProgressHUD.h"
#import "GuideViewController.h"

@interface RootViewController ()<UIActionSheetDelegate>
@property (nonatomic, strong)AVAudioPlayer *player;
@property (nonatomic, assign)BOOL kStopPlaySound;

@end

@implementation RootViewController
@synthesize player = _player;
@synthesize kStopPlaySound = kStopPlaySound_;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    //测试字体family功能
//    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
//    {
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames = [[NSArray alloc] initWithArray:
//                     [UIFont fontNamesForFamilyName:
//                      [familyNames objectAtIndex:indFamily]]];
//        for (indFont=0; indFont<[fontNames count]; ++indFont)
//        {
//            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
//        }  
//    }
    
}
- (IBAction)doNothing:(UIButton *)sender {
    [SVProgressHUD showSuccessWithStatus:@"期待下一个版本哟"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setUp];
    
    BOOL firstShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstShow"];
    if (!firstShow) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GuideViewController *guide = [sb instantiateViewControllerWithIdentifier:@"guideVC"];
        [self presentViewController:guide animated:YES completion:nil];
        
    }
}

- (AVAudioPlayer *)player
{
    if (!_player)
    {
        NSURL *fileURL = [[NSBundle mainBundle]URLForResource:@"sound" withExtension:@"mp3"];
        if ([[NSFileManager defaultManager]fileExistsAtPath:[fileURL path]])
        {
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL fileTypeHint:AVFileTypeMPEGLayer3 error:nil];
            _player.numberOfLoops = -1;
            
            [_player prepareToPlay];
        }

    }
    return _player;
    
}
- (void)setUp
{
    self.kStopPlaySound = [[NSUserDefaults standardUserDefaults]boolForKey:@"kStopPlaySound"];
    [self playServiceSound];
}
- (void)setKStopPlaySound:(BOOL)kStopPlaySound
{
    if (kStopPlaySound_ != kStopPlaySound)
    {
        kStopPlaySound_ = kStopPlaySound;
        [[NSUserDefaults standardUserDefaults] setBool:kStopPlaySound_ forKey:@"kStopPlaySound"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (kStopPlaySound_ == YES)
    {
        self.player = nil;
    }
}

#pragma mark - SoundService
- (void)playServiceSound
{
    if (!kStopPlaySound_ && self.player && ![self.player isPlaying])
    {
        [self.player play];
    }
}

- (void)pauseServiceSound
{
    if (self.player && [self.player isPlaying] ) {
        [self.player pause];
    }
}

- (void)stopServiceSound
{
    self.kStopPlaySound = YES;
    if (self.player)
    {
        [self.player stop];
        self.player = nil;
    }
}

- (void)startPlayingSound
{
    self.kStopPlaySound = NO;
    
    [self playServiceSound];
}

- (void)changeSoundService
{
    if (kStopPlaySound_)
    {
        [self startPlayingSound];
    }
    else
    {
        [self stopServiceSound];
    }
}
#pragma mark - action sheet
- (IBAction)setting:(UIButton *)sender
{

    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"设置"
                                                       delegate:self
                                              cancelButtonTitle:@"关闭"
                                         destructiveButtonTitle:kStopPlaySound_ ? @"打开背景音乐" : @"关闭背景音乐"
                                              otherButtonTitles:@"意见反馈" ,@"检查更新" ,@"关于我们" ,nil];
    action.backgroundColor = [UIColor redColor];
    action.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {//关闭背景音乐
            [self changeSoundService];
        }
            break;
        case 1:
        {
            [self emailToDeveloper];
        }
            break;
        case 2:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)emailToDeveloper
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc]init];
        [self presentViewController:emailVC animated:YES completion:nil];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"请先设置你的邮箱"];
        
    }
}
@end
