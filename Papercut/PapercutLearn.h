//
//  PapercutLearn.h
//  Papercut
//
//  Created by jackie on 15/3/4.
//  Copyright (c) 2015年 jackie. All rights reserved.
//

#import "JSONModel.h"

@protocol LearnModel
@end
@interface LearnModel : JSONModel

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *base_url;
@property (nonatomic, assign) NSInteger count;
@end

@interface PapercutLearn : JSONModel

@property (nonatomic, strong) NSString *group_title;
@property (nonatomic, strong) NSArray<LearnModel> * items;

@end
