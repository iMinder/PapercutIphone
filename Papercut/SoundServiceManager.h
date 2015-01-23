//
//  SoundServiceManager.h
//  Papercut
//
//  Created by jackie on 15/1/20.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundServiceManager : NSObject

+ (instancetype)sharedInstance;

- (void)playServiceSound;
- (void)pauseServiceSound;
- (void)stopeServiceSound;
- (void)startPlayingSound;

@end
