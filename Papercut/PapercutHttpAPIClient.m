//
//  PapercutHttpAPIClient.m
//  Papercut
//
//  Created by jackie on 15/2/5.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "PapercutHttpAPIClient.h"

static NSString *const BaseURLString = @"http://papercut.jd-app.com";

@implementation PapercutHttpAPIClient

+(instancetype)sharedClient
{
    static PapercutHttpAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PapercutHttpAPIClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
    });
    
    return _sharedClient;
    
}

@end
