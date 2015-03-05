//
//  AboutRootViewController.m
//  Papercut
//
//  Created by jackie on 15/3/5.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "AboutRootViewController.h"

@interface AboutRootViewController ()

@end

@implementation AboutRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    items = @[@"软件版本",@"软件介绍",@"开发人员",@"致谢"];
    icons = @[@"about_version",@"about_software",@"about_team",@"about_thanks"];

    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                                           action:@selector(dismiss:)];
    self.navigationItem.rightBarButtonItem = close;
    self.title = NSLocalizedString(@"About Us", @"About Us");
    
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.clipsToBounds = YES;
    
}

- (void)dismiss:(id)sender{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_ID";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    [cell.imageView setImage:[UIImage imageNamed:icons[indexPath.row]]];
    cell.textLabel.text = items[indexPath.row];
    cell.detailTextLabel.text = @"";
    if (indexPath.row == 0) {
        cell.detailTextLabel.text =
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    [self performSegueWithIdentifier:icons[indexPath.row] sender:nil];
    
}
@end
