//
//  HCategoryModel.m
//  HCategoryModel
//
//  Created by Superbil on 13/9/8.
//  Copyright (c) 2013年 Superbil. All rights reserved.
//

#import "HCategoryModel.h"
#import <FMDB/FMDatabaseQueue.h>

static NSString *kDefaultTableName = @"category";

NSInteger kRootCategory = 1;
NSInteger kUnfiedCategory = 0;

#pragma mark - HCategory Category for FMResutSet

@interface HCategory (FMResutSet)
+ (id)categoryWithResultSet:(FMResultSet *)resultSet;
@end

@implementation HCategory (FMResutSet)

+ (id)categoryWithResultSet:(FMResultSet *)resultSet {
    return [[HCategory alloc] initWithIdentify:[resultSet intForColumnIndex:0]
                                                         left:[resultSet intForColumnIndex:1]
                                                        right:[resultSet intForColumnIndex:2]
                                                        depth:[resultSet intForColumnIndex:3]
                                                         name:[resultSet stringForColumnIndex:4]];
}

@end

#pragma mark - Private define

@interface HCategoryModel (PrivateMethod)
- (NSString *)selectCategoryCommandWithIndexID:(NSInteger)indexID;
- (BOOL)checkDatabase;
- (BOOL)runCommandFromCommands:(NSArray *)commands;
- (NSArray *)listCategoryWithCommand:(NSString *)sqlCommand;
- (NSArray *)listCategoryWithCategoryName:(NSString *)categoryName
                            categoryDepth:(NSInteger)categoryDepth;
- (NSString *)formattedString:(NSString *)string;
@end

@implementation HCategoryModel

@synthesize database = database_;
@synthesize databasePath = path_;
@synthesize tableName = tableName_;

#pragma mark - Initial and dealloc

- (id)initWithDatabasePath:(NSString *)path {
    if (self = [super init]) {
        database_ = [[FMDatabase alloc] initWithPath:path];
        path_ = path;
        tableName_ = kDefaultTableName;
    }
    return self;
}

#pragma mark - Private method

- (NSString *)selectCategoryCommandWithIndexID:(NSInteger)indexID {
    return [NSString stringWithFormat:@"SELECT left, right, depth, name FROM %@ WHERE rowid=%d", self.tableName, indexID];
}

- (BOOL)checkDatabase {

    // while |self.databasePath| is @"", that can make tempuate database in memory
    if ([self.databasePath isEqualToString:@""]) {
        return YES;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:self.databasePath] == NO) {
        return [self createDatabase];
    } else {
        NSLog(@"DATABASE IS EXIST AT %@", self.databasePath);
        if (![self.database open]) {
            return NO;
        }
            
        return YES;
    }
}

- (BOOL)runCommandFromCommands:(NSArray *)commands {
    [self.database beginTransaction];
    for (NSString *command in commands) {
        if (![self.database executeUpdate:command]) {
            [self.database rollback];
            return NO;
        }
    }
    [self.database commit];
    return YES;
}

- (NSArray *)listCategoryWithQueryCommand:(NSString *)queryCommand {
    NSString *command =
    [NSString stringWithFormat:@"SELECT rowid, left, right, depth, name FROM %@", self.tableName];
    
    if (queryCommand) {
        command = [command stringByAppendingFormat:@" WHERE %@", queryCommand];
    }
    
    FMResultSet *resultSet = [self.database executeQuery:command];

    NSMutableArray *categorys = [NSMutableArray array];
    
    while ([resultSet next]) {
        HCategory *newCategory = [HCategory categoryWithResultSet:resultSet];
        [categorys addObject:newCategory];
    }
    
    return categorys;
}

- (NSArray *)listCategoryWithCategoryLeft:(NSInteger)categoryLeft
                            categoryRight:(NSInteger)categoryRight
                            categoryDepth:(NSInteger)categoryDepth {
    NSString *command = [NSString stringWithFormat:@"left < %d AND %d < right AND depth = %d",
                         categoryLeft,
                         categoryRight,
                         categoryDepth];
    return [self listCategoryWithQueryCommand:command];
}

- (NSArray *)listCategoryWithCategoryName:(NSString *)categoryName
                            categoryDepth:(NSInteger)categoryDepth {
    NSString *command =
    [NSString stringWithFormat:@"name = '%@'", categoryName];
    if (categoryDepth > 0) {
        command = [command stringByAppendingFormat:@"AND depth = %d", categoryDepth];
    }
    return [self listCategoryWithQueryCommand:command];
}

- (NSString *)formattedString:(NSString *)string {
    return [NSString stringWithCString:sqlite3_mprintf("%q", [string UTF8String]) encoding:NSUTF8StringEncoding];
}


#pragma mark - Implementation method

- (void)openDatabase {
    [self checkDatabase];
}

- (void)closeDatabase {
    [self.database close];
}

- (BOOL)createDatabase {
    NSString *createDatabase =
    [NSString stringWithFormat:@"\
     CREATE TABLE IF NOT EXISTS %@(\
     name VARCHAR(20) NOT NULL,\
     left INT NOT NULL,\
     right INT NOT NULL,\
     depth INT NO NULL\
     );", self.tableName];
    
    NSString *rootCategory =
    [NSString stringWithFormat:@"INSERT INTO %@ (left, right, depth, name) VALUES (1,2,0,'root');", self.tableName];
    
    NSLog(@"creat database at %@", self.databasePath);
    if (![self.database open]) {
        return NO;
    }

    for (NSString *command in @[createDatabase, rootCategory]) {
        if ([self.database executeUpdate:command] == NO) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)dropDatabase {
    NSString *dropCommand = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", self.tableName];
    return [self.database executeUpdate:dropCommand];
}

- (NSArray *)listCategory {
    return [self listCategoryWithQueryCommand:nil];
}

- (NSArray *)listCategoryWithCategoryID:(NSInteger)categoryID {
    HCategory *parentVCF = [self categoryWithCategoryID:categoryID];
    NSString *command =
    [NSString stringWithFormat:@"depth = %d + 1 AND left BETWEEN %d AND %d",
     parentVCF.depth,
     parentVCF.left,
     parentVCF.right];
    return [self listCategoryWithQueryCommand:command];
}

- (HCategory *)categoryWithCategoryID:(NSInteger)categoryID {

    NSString *command = [self selectCategoryCommandWithIndexID:categoryID];

    FMResultSet *resultSet = [self.database executeQuery:command];

    while ([resultSet next]) {
        HCategory *newCategory =
        [[HCategory alloc] initWithIdentify:categoryID
                                       left:[resultSet intForColumnIndex:0]
                                      right:[resultSet intForColumnIndex:1]
                                      depth:[resultSet intForColumnIndex:2]
                                       name:[resultSet stringForColumnIndex:3]];
        return newCategory;
    }

    return nil;
}

- (HCategory *)parentCategoryWithCategoryID:(NSInteger)categoryID {
    HCategory *category = [self categoryWithCategoryID:categoryID];
    return [[self listCategoryWithCategoryLeft:category.left
                                 categoryRight:category.right
                                 categoryDepth:category.depth - 1]
            objectAtIndex:0];
}

- (NSInteger)insertCategoryWithName:(NSString *)name
                       atCategoryID:(NSInteger)targetCategoryID {
    
    [self openDatabase];
    
    HCategory *targetCategory = [self categoryWithCategoryID:targetCategoryID];
    
    // while command is failed, go out
    if (targetCategory == nil) {
        return NO;
    }
    
    NSString *rightUpdateCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET right = right + 2 WHERE right >= %d",
     self.tableName,
     targetCategory.right];
    
    
    NSString *leftUpdateCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET left = left + 2 WHERE left > %d",
     self.tableName,
     targetCategory.right];
    
    NSString *insertCategoryName = [self formattedString:name];
    NSString *insertCommand =
    [NSString stringWithFormat:@"INSERT INTO %@ (left, right, depth, name) VALUES (%d,%d,%d,'%@');",
     self.tableName,
     targetCategory.right,
     targetCategory.right + 1,
     targetCategory.depth + 1,
     insertCategoryName];
    
    NSArray *commands = @[rightUpdateCommand, leftUpdateCommand, insertCommand];
    if ([self runCommandFromCommands:commands] == NO) {
        return NO;
    }
    
    HCategory *insertCategory =
    [[self listCategoryWithCategoryName:insertCategoryName
                          categoryDepth:targetCategory.depth + 1] objectAtIndex:0];

    return insertCategory.identify;
}

- (BOOL)moveCategory:(HCategory *)sourceCategory
          toCategory:(HCategory *)targetCategory {
    [self openDatabase];
    
    // 1. 把 source 的 index 都變成負的 (keep)
    // a = (source.left - 1).id 保存起來
    NSInteger width = sourceCategory.right - sourceCategory.left + 1;
    NSString *tempSourceCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET left = left * -1, right = right * -1 WHERE left >= %d AND right <= %d;",
     self.tableName,
     sourceCategory.left,
     sourceCategory.right];
    
    // 2. 把目標的空間騰出來
    // 把 source 點的 *右減左的值* (寬度) 加到 target.right 及之後的點
    // 更新右點
    NSString *createWidthOnTargetCategoryRightCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET right = right + %d WHERE right >= %d",
     self.tableName,
     width,
     targetCategory.right];
    
    // 更新左點
    NSString *createWidthOnTargetCategoryLeftCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET left = left + %d WHERE left > %d",
     self.tableName,
     width,
     targetCategory.right];
    
    // 3. 把騰出來的空間清掉
    // 大於 source.right 右邊都要更新
    // 更新右點
    NSString *removeTempRightCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET right = right - %d WHERE right > %d",
     self.tableName,
     width,
     sourceCategory.right];
    
    // 更新左點
    NSString *removeTempLeftCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET left = left - %d WHERE left > %d",
     self.tableName,
     width,
     sourceCategory.right];
    
    NSArray *commands = @[tempSourceCommand,
                          createWidthOnTargetCategoryRightCommand,
                          createWidthOnTargetCategoryLeftCommand,
                          removeTempRightCommand,
                          removeTempLeftCommand,
                          ];

    if ([self runCommandFromCommands:commands] == NO) {
        return NO;
    }
    
    // 4 .移動 source 的 index
    // 把 target.left 加上到 source 的每一個點上
    // Note: 需要抓取更新過後的 新 targetCategor
    HCategory *newTargetCategory = [self categoryWithCategoryID:targetCategory.identify];
    
    // newTargetCategory.right - width 是為了將移動的點放在 newTarget 的最右邊
    NSInteger fixWidth = -sourceCategory.left + (newTargetCategory.right - width);
    
    NSString *moveSourceCategoryToTargetCategoryCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET left = left * -1 + %d, right = right * -1 + %d, depth = depth + %d WHERE left < 0",
     self.tableName,
     fixWidth,
     fixWidth,
     -sourceCategory.depth + newTargetCategory.depth + 1];

    if ([self runCommandFromCommands:@[moveSourceCategoryToTargetCategoryCommand]] == NO) {
        return NO;
    }

    return YES;
}

- (BOOL)updateCategory:(HCategory *)category {
    
    if (category.identify == 0) {
        return NO;
    }
    
    NSString *updateName = [self formattedString:category.name];
    
    NSString *command =
    [NSString stringWithFormat:@"UPDATE %@ SET name = '%@' WHERE rowid=%d",
     self.tableName,
     updateName,
     category.identify];
    
    [self openDatabase];
    
    return [self.database executeUpdate:command];
}

- (BOOL)deleteCategory:(HCategory *)category {
    if (category.identify == 0 || category.left == 0 || category.right == 0) {
        return NO;
    }
    
    [self openDatabase];
    
    NSInteger width = category.right - category.left + 1;
    
    // delete category
    NSString *deleteCommand =
    [NSString stringWithFormat:@"DELETE FROM %@ WHERE left BETWEEN %d AND %d",
     self.tableName,
     category.left,
     category.right];
    
    NSString *rightUpdateCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET right = right - %d WHERE right > %d",
     self.tableName,
     width,
     category.right];
    
    
    NSString *leftUpdateCommand =
    [NSString stringWithFormat:@"UPDATE %@ SET left = left - %d WHERE left > %d" ,
     self.tableName,
     width,
     category.right];
    
    NSArray *commands = @[deleteCommand, rightUpdateCommand, leftUpdateCommand];
    if ([self runCommandFromCommands:commands] == NO) {
        return NO;
    }
    
    return YES;
}

@end