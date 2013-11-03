//
//  HCategory.h
//  HCategoryModel
//
//  Created by Superbil on 13/9/8.
//  Copyright (c) 2013年 Superbil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCategory : NSObject

/**
 建立 HCategory 的實體
 @param identify 類別的唯一值
 @param left 類別的左節點值
 @param right 類別的右節點值
 @param depth 類別的在整個樹中的深度
 @name 類別的名稱
 @returns 類別的實體
 */
- (id)initWithIdentify:(NSInteger)identify
                  left:(NSInteger)left
                 right:(NSInteger)right
                 depth:(NSInteger)depth
                  name:(NSString *)name;

/// 左邊節點的值
@property (assign, nonatomic, readonly) NSInteger left;

/// 右邊節點的值
@property (assign, nonatomic, readonly) NSInteger right;

/// 類別的深度
@property (assign, nonatomic, readonly) NSInteger depth;

/// 類別辨別的唯一值
@property (assign, nonatomic, readonly) NSInteger identify;

/// 類別的名稱
@property (strong, nonatomic) NSString *name;

@end
