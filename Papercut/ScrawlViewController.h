//
//  ScrawlViewController.h
//  Papercut
//
//  Created by jackie on 15/2/16.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDThumbnailView;
@class WDBlockingView;
@interface ScrawlViewController : UIViewController
{
    WDThumbnailView *editingThumbnail_;
    WDBlockingView *blockingView_;
    
    UIActionSheet *deleteSheet_;
    
    NSUInteger centeredIndex;
    
    NSMutableSet *savingPaintings;
    
}

@end
