//
//  PapercutUtility.m
//  Papercut
//
//  Created by jackie on 15/1/30.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "PapercutUtility.h"
#import "UIDeviceHardware.h"

@implementation PapercutUtility


int systemVersion()
{
    static dispatch_once_t onceToken;
    static PapercutUtility *papercut = nil;
    static int version = 0;
    dispatch_once(&onceToken, ^{
        papercut = [PapercutUtility new];
        NSString *systemName = [UIDeviceHardware platform];
        NSScanner *scanner = [[NSScanner alloc]initWithString:systemName];
        NSString *model = nil;
      
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&model];
        [scanner scanInt:&version];
    });
    return version;
}
@end
