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

@interface RootViewController ()
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
    self.navigationController.hidesBarsOnTap = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUp];
}

- (void)setUp
{
    
    if (!_player) {
        NSURL *fileURL = [[NSBundle mainBundle]URLForResource:@"sound" withExtension:@"mp3"];
        if ([[NSFileManager defaultManager]fileExistsAtPath:[fileURL path]])
        {
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL fileTypeHint:AVFileTypeMPEGLayer3 error:nil];
            self.player.numberOfLoops = -1;
            self.kStopPlaySound = [[NSUserDefaults standardUserDefaults]boolForKey:@"kStopPlaySound"];
            
            [self.player prepareToPlay];
            
            [self playServiceSound];
        }
    }
}
- (void)setKStopPlaySound:(BOOL)kStopPlaySound
{
    if (kStopPlaySound_ != kStopPlaySound) {
        kStopPlaySound_ = kStopPlaySound;
        [[NSUserDefaults standardUserDefaults] setBool:kStopPlaySound_ forKey:@"kStopPlaySound"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - SoundService
- (void)playServiceSound
{
    if (self.player && ![self.player isPlaying] && !kStopPlaySound_) {
        [self.player play];
    }
}

- (void)pauseServiceSound
{
    if (self.player && [self.player isPlaying] ) {
        [self.player pause];
    }
}

- (void)stopeServiceSound
{
    self.kStopPlaySound = YES;
    if (self.player) {
        [self.player stop];
    }
}

- (void)startPlayingSound
{
    self.kStopPlaySound = NO;
    
    [self playServiceSound];
}

@end
