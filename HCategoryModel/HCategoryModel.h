//
//  HCategoryModel.h
//  HCategoryModel
//
//  Created by Superbil on 13/9/8.
//  Copyright (c) 2013年 Superbil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabase.h>
#import "HCategory.h"

extern NSInteger kRootCategory;
extern NSInteger kUnfiedCategory;

@interface HCategoryModel : NSObject {
    FMDatabase *database_;
    NSString *path_;
    NSString *tableName_;
}

@property (nonatomic, strong) FMDatabase *database;

// 資料庫路徑
@property (nonatomic, strong, readonly) NSString *databasePath;

@property (nonatomic, strong) NSString *tableName;

- (id)initWithDatabasePath:(NSString *)path;

// 若開啟的時候不存在 database 會建立並呼叫 |createDatabase|
- (void)openDatabase;

// 關閉資料庫
- (void)closeDatabase;

// 建立資料庫
// 回傳為執行是否成功
- (BOOL)createDatabase;

// 把 table 丟掉
// 回傳為執行是否成功
- (BOOL)dropDatabase;

// 列出全部的纇別清單
// 回傳為 PPVCFCategory 的陣列
- (NSArray *)listCategory;

// 從 category.id 來列出清單，這只會回傳該 category 下的那一層而已
// |indexID| 為要查詢要 category id
- (NSArray *)listCategoryWithCategoryID:(NSInteger)categoryID;

// 從 category.id 來抓取類別資料
- (HCategory *)categoryWithCategoryID:(NSInteger)categoryID;

// 從 category.id 來查詢 parent
- (HCategory *)parentCategoryWithCategoryID:(NSInteger)categoryID;

// 插入新的 category
// |name| 要插入的 category name
// |targetCategoryID| 插入的目標
// 回傳為新插入的 category ID
- (NSInteger)insertCategoryWithName:(NSString *)name
                       atCategoryID:(NSInteger)targetCategoryID;

// 移動 |sourceCategory| 到 |targetCategory| 之下
// |sourceCategory| 要移動的來源
// |targetCategory| 要移動到的目標
// 回傳為執行是否成功
- (BOOL)moveCategory:(HCategory *)sourceCategory
          toCategory:(HCategory *)targetCategory;

// 更新 category 的名稱
// |category| 要被更新的內容
// 回傳為執行是否成功
- (BOOL)updateCategory:(HCategory *)category;

// 刪除 category
// |category| 要被刪除的 category
// 回傳為執行是否成功
- (BOOL)deleteCategory:(HCategory *)categroy;

@end
