//
//  AppDelegate.m
//  Papercut
//
//  Created by jackie on 14-5-25.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "PaperCutAppDelegate.h"
#import "SoundServiceManager.h"
#import "SVProgressHUD.h"
#import "MobClick.h"
#import "UMFeedback.h"
//#import "UMSocial.h"

#define RGBA(r,g,b,a) [UIColor \
                        colorWithRed:r\
                        green:g \
                        blue:b  \
                        alpha:a]



@implementation PaperCutAppDelegate

- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //      [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
    //反馈注册
    [UMFeedback setAppkey:UMENG_APPKEY];
    
    //分享key
    //[UMSocialData setAppKey:UMENG_APPKEY];
    
    
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}

- (void)setup
{
  
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
   
    //设置背景色
//    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"top_bar"] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setBarTintColor:RGBA(216.0/255.0, 0, 23.0/255.0, 1.0)];

    [[UIToolbar appearance] setBarTintColor:RGBA(216.0/255.0, 0, 23.0/255.0, 1.0)];
    
//    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bar"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
   // [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"world_blank"] forBarMetrics:UIBarMetricsDefault];
    //[[UIToolbar appearance]setTintColor:[UIColor whiteColor]];
    //设置navigation 里面的字体颜色
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]
                                 
                                 };
    
    [[UINavigationBar appearance]setTitleTextAttributes:attributes];
    
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    [[SVProgressHUD appearance] setHudBackgroundColor:[UIColor blackColor]];
    [[SVProgressHUD appearance] setHudForegroundColor:[UIColor whiteColor]];
    [[SVProgressHUD  appearance] setHudErrorImage:[UIImage imageNamed:@"error"]];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setup];
    
    [self umengTrack];
    return YES;
}
							
@end
