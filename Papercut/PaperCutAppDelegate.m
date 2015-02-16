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

#define RGBA(r,g,b,a) [UIColor \
                        colorWithRed:r \
                        green:g \
                        blue:b  \
                        alpha:a]

@implementation PaperCutAppDelegate

- (void)setup
{
  
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    
//    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"top_bar"] forBarMetrics:UIBarMetricsDefault];

   [[UINavigationBar appearance] setBarTintColor:[UIColor redColor]];

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
    return YES;
}
							
@end
