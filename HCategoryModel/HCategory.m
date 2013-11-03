//
//  HCategory.m
//  HCategoryModel
//
//  Created by Superbil on 13/9/8.
//  Copyright (c) 2013年 Superbil. All rights reserved.
//

#import "HCategory.h"

@implementation HCategory

@synthesize identify = identify_;
@synthesize left = left_;
@synthesize right = right_;
@synthesize depth = depth_;
@synthesize name = name_;

- (id)initWithIdentify:(NSInteger)identify
                  left:(NSInteger)left
                 right:(NSInteger)right
                 depth:(NSInteger)depth
                  name:(NSString *)name {
    self = [super init];
    if (self) {
        identify_ = identify;
        left_ = left;
        right_ = right;
        depth_ = depth;
        name_ = name;
    }
    return self;
}

- (void)dealloc {
    name_ = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"id:%d left:%d right:%d depth:%d name:%@",
            self.identify,
            self.left,
            self.right,
            self.depth,
            self.name];
}

@end
