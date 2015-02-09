//
//  SoundServiceManager.m
//  Papercut
//
//  Created by jackie on 15/1/20.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "SoundServiceManager.h"
#import <AVFoundation/AVFoundation.h>
@interface SoundServiceManager()<AVAudioPlayerDelegate>


@property (nonatomic, strong)NSURL *fileURL;
@property (nonatomic, strong)AVAudioPlayer *player;
@property (nonatomic, assign)BOOL kStopPlaySound;

@end

@implementation SoundServiceManager
@synthesize kStopPlaySound = kStopPlaySound_;
@synthesize player = _player;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SoundServiceManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[SoundServiceManager alloc]init];
        
    });
    return manager;
}

- (AVAudioPlayer *)player
{
    if (!_player) {
        self.fileURL = [[NSBundle mainBundle]URLForResource:@"sound" withExtension:@"mp3"];
        if ([[NSFileManager defaultManager]fileExistsAtPath:[self.fileURL path]])
        {
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.fileURL fileTypeHint:AVFileTypeMPEGLayer3 error:nil];
            _player.numberOfLoops = -1;
            _player.volume = 1.0;
            self.kStopPlaySound = YES;
            [_player prepareToPlay];
        }
    }
    return _player;
}



- (void)playServiceSound
{
    if (self.player && ![self.player isPlaying] && self.kStopPlaySound) {
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
    self.kStopPlaySound = NO;
    if (self.player) {
        [self.player stop];
    }
}

- (void)startPlayingSound
{
    self.kStopPlaySound = YES;
    
    [self playServiceSound];
}

@end
