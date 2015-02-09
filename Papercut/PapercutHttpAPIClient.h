//
//  PapercutHttpAPIClient.h
//  Papercut
//
//  Created by jackie on 15/2/5.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "AFNetworking.h"

@interface PapercutHttpAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
