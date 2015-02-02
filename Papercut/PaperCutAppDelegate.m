//
//  AppDelegate.m
//  Papercut
//
//  Created by jackie on 14-5-25.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "PaperCutAppDelegate.h"
#import "SoundServiceManager.h"

#define RGBA(r,g,b,a) [UIColor \
                        colorWithRed:r \
                        green:g \
                        blue:b  \
                        alpha:a]

@implementation PaperCutAppDelegate

- (void)setup
{
  
   // [[UIToolbar appearance]setBarTintColor:RGBA(249,246,147,1.0)];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"top_bar"] forBarMetrics:UIBarMetricsDefault];

    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bar"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
   // [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"world_blank"] forBarMetrics:UIBarMetricsDefault];
    //[[UIToolbar appearance]setTintColor:[UIColor whiteColor]];
    //设置navigation 里面的字体颜色
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]
                                 
                                 };
    
    [[UINavigationBar appearance]setTitleTextAttributes:attributes];
    
    //设置返回按钮的颜色
//    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class] ,nil]setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setup];
    return YES;
}
							
@end
