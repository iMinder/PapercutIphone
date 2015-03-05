//
//  AboutRootViewController.h
//  Papercut
//
//  Created by jackie on 15/3/5.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutRootViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *items;
    NSArray *icons;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
