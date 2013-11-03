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

/// 母類別
extern NSInteger kRootCategory;
/// 未分類的類別
extern NSInteger kUnfiedCategory;

@interface HCategoryModel : NSObject {
    FMDatabase *database_;
    NSString *path_;
    NSString *tableName_;
}

/// 資料庫實體
@property (nonatomic, strong) FMDatabase *database;

/// 資料庫路徑
@property (nonatomic, strong, readonly) NSString *databasePath;

/// 建立的表格名稱
@property (nonatomic, strong) NSString *tableName;

/**
 使用 |path| 的路徑來建立資料庫
 @param path 資料庫路徑
 @return HCategoryModel 的實體
 */
- (id)initWithDatabasePath:(NSString *)path;

/**
 開啟資料庫，若開啟的時候不存在 database 會建立並呼叫 |createDatabase|
 @returns 回傳為執行是否成功
 */
- (BOOL)openDatabase;

/**
 關閉資料庫
 @returns 回傳為執行是否成功
 */
- (void)closeDatabase;

/**
 建立資料庫
 @returns 回傳為執行是否成功
 */
- (BOOL)createDatabase;

/**
 把 table 丟掉
 @returns 回傳為執行是否成功
 */
- (BOOL)dropDatabase;

/**
 列出全部的纇別清單
 @returns 回傳為 PPVCFCategory 的陣列
 */
- (NSArray *)listCategory;

/**
 從 categoryID 來列出清單，這只會回傳該 category 下的那一層而已
 @param categoryID 要查詢的 category identifier
 @returns 回傳 categoryID 下面的子類別
 */
- (NSArray *)listCategoryWithCategoryID:(NSInteger)categoryID;

/**
 category.id 來抓取類別資料
 @param categoryID 要查詢的 category id
 @returns 回傳查詢到的 HCategory
 */
- (HCategory *)categoryWithCategoryID:(NSInteger)categoryID;

/**
 從 category.id 來查詢 parent
 @param categoryID 要查詢的 category id
 @returns 回傳 categoryID 的上一層 HCategory
 */
- (HCategory *)parentCategoryWithCategoryID:(NSInteger)categoryID;

/**
 插入新的 category
 @param name 要插入的 category name
 @param targetCategoryID 插入的目標
 @returns 回傳為新插入的 category ID
 */
- (NSInteger)insertCategoryWithName:(NSString *)name
                       atCategoryID:(NSInteger)targetCategoryID;

/**
 移動 sourceCategory 到 targetCategory 之下
 @param sourceCategory 要移動的來源
 @param targetCategory 要移動到的目標
 @returns 回傳為執行是否成功
 */
- (BOOL)moveCategory:(HCategory *)sourceCategory
          toCategory:(HCategory *)targetCategory;

/**
 更新 category 的名稱
 @param category 要被更新的內容
 @returns 回傳為執行是否成功
 */
- (BOOL)updateCategory:(HCategory *)category;

/**
 刪除 category
 @param category 要被刪除的 category
 @returns 回傳為執行是否成功
 */
- (BOOL)deleteCategory:(HCategory *)categroy;

@end
