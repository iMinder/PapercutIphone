//
//  AppDelegate.m
//  Papercut
//
//  Created by jackie on 14-5-25.
//  Copyright (c) 2014年 jackie. All rights reserved.
//

#import "PaperCutAppDelegate.h"
#import "SoundServiceManager.h"

@implementation PaperCutAppDelegate

- (void)setup
{
    //[[SoundServiceManager sharedInstance] playServiceSound];
    [[UIToolbar appearance]setBarTintColor:[UIColor redColor]];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance]setBarTintColor:[UIColor redColor]];
    [[UIToolbar appearance]setTintColor:[UIColor whiteColor]];
    //设置navigation 里面的字体颜色
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]
                                 
                                 };
    
    [[UINavigationBar appearance]setTitleTextAttributes:attributes];
    
    
    //设置返回按钮的颜色
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class] ,nil]setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setup];
    return YES;
}
							
@end
