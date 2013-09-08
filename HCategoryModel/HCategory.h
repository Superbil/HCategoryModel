//
//  HCategory.h
//  HCategoryModel
//
//  Created by Superbil on 13/9/8.
//  Copyright (c) 2013年 Superbil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCategory : NSObject

- (id)initWithIdentify:(NSInteger)identify
                  left:(NSInteger)left
                 right:(NSInteger)right
                 depth:(NSInteger)depth
                  name:(NSString *)name;

@property (assign, nonatomic, readonly) NSInteger left;

@property (assign, nonatomic, readonly) NSInteger right;

@property (assign, nonatomic, readonly) NSInteger depth;

@property (assign, nonatomic, readonly) NSInteger identify;

@property (strong, nonatomic) NSString *name;

@end
