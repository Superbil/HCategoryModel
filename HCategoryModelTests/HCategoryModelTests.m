//
//  HCategoryModelTests.m
//  HCategoryModelTests
//
//  Created by Superbil on 13/9/8.
//  Copyright (c) 2013 年 Superbil. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "HCategoryModel.h"

#define Delete_Datebase 1

@interface HCategoryModelTests : SenTestCase
@property (nonatomic, strong) HCategoryModel *categoryModel;
@end

@implementation HCategoryModelTests

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)setUp
{
    [super setUp];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self applicationDocumentsDirectory]] == NO) {
        [fileManager createDirectoryAtPath:[self applicationDocumentsDirectory]
               withIntermediateDirectories:YES
                                attributes:nil error:nil];
    }

    NSString *databaseName = @"test.db";
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:databaseName];

    self.categoryModel = [[HCategoryModel alloc] initWithDatabasePath:path];
#if Delete_Datebase
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
#else
    [self.categoryModel dropDatabase];
#endif
    STAssertTrue([self.categoryModel createDatabase], nil);
}

- (void)tearDown
{
    [self.categoryModel closeDatabase];
    self.categoryModel = nil;

    [super tearDown];
}

- (void)insertTestData {
    // insert at root
    NSInteger insertCategoryID = [self.categoryModel insertCategoryWithName:@"firstNode" atCategoryID:kRootCategory];
    STAssertTrue(insertCategoryID > 1, nil);
}

- (void)testGetFromID {
    [self cleanTree];
    [self insertTestData];

    HCategory *vcf = [self.categoryModel categoryWithCategoryID:2];
    STAssertNotNil(vcf, nil);

    // check vcf
    STAssertTrue(vcf.identify == 2, nil);
    STAssertTrue(vcf.left == 2, nil);
    STAssertTrue(vcf.right == 3, nil);
    STAssertTrue([vcf.name compare:@"firstNode"] == NSOrderedSame, nil);

    HCategory *rootVcf = [self.categoryModel categoryWithCategoryID:1];

    // root must been update
    STAssertTrue(rootVcf.right == 4, nil);
}

- (void)testUpdate {
    [self cleanTree];
    [self insertTestData];

    NSString *newName = @"this is a new name";
    HCategory *vcf = [self.categoryModel categoryWithCategoryID:2];
    vcf.name = newName;

    STAssertTrue([self.categoryModel updateCategory:vcf], nil);

    // check newVCF

    HCategory *newVcf = [self.categoryModel categoryWithCategoryID:2];
    STAssertNotNil(newVcf, nil);

    // check vcf
    STAssertTrue(newVcf.identify == 2, nil);
    STAssertTrue([newVcf.name compare:newName] == NSOrderedSame, nil);
}

- (void)testDelete {
    [self.categoryModel dropDatabase];
    [self.categoryModel createDatabase];
    [self insertTestData];

    STAssertTrue([[self.categoryModel listCategory] count] == 2, nil);

    HCategory *vcf = [self.categoryModel categoryWithCategoryID:2];
    STAssertNotNil(vcf, nil);

    STAssertTrue([self.categoryModel deleteCategory:vcf], nil);
    STAssertTrue([[self.categoryModel listCategory] count] == 1, nil);
}

- (void)cleanTree {
    // clean database, only need root node
    NSArray *categories = [self.categoryModel listCategory];
    if ([categories count] > 1) {
        for (HCategory *vcf in categories) {
            if (vcf.identify != 1) {
                [self.categoryModel deleteCategory:vcf];
            }
        }
    }
}

- (void)testMoveSample {
    [self cleanTree];

    [self.categoryModel insertCategoryWithName:@"A" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"B" atCategoryID:2];


    HCategory *rootCategory = [self.categoryModel categoryWithCategoryID:kRootCategory];
    HCategory *moveCategory = [self.categoryModel categoryWithCategoryID:3];

    [self.categoryModel moveCategory:moveCategory toCategory:rootCategory];

    NSArray *categories = [self.categoryModel listCategory];
    for (HCategory *vcf in categories) {
        switch (vcf.identify) {
            case 1:
                STAssertTrue(vcf.left == kRootCategory, nil);
                STAssertTrue(vcf.right == 6, nil);
                STAssertTrue(vcf.depth == 0, nil);
                break;

            case 2:
                STAssertTrue(vcf.left == 2, nil);
                STAssertTrue(vcf.right == 3, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 3:
                STAssertTrue(vcf.left == 4, nil);
                STAssertTrue(vcf.right == 5, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;
        }
    }
}

- (void)testMoveHard_Left2Right {
    [self cleanTree];

    [self.categoryModel insertCategoryWithName:@"A" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"B" atCategoryID:2];
    [self.categoryModel insertCategoryWithName:@"C" atCategoryID:2];
    [self.categoryModel insertCategoryWithName:@"D" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"E" atCategoryID:5];
    [self.categoryModel insertCategoryWithName:@"F" atCategoryID:kRootCategory];

    HCategory *a = [self.categoryModel categoryWithCategoryID:2];
    HCategory *e = [self.categoryModel categoryWithCategoryID:6];

    // move A to E
    [self.categoryModel moveCategory:a toCategory:e];

    for (HCategory *vcf in [self.categoryModel listCategory]) {
        switch (vcf.identify) {
            case 1:
                STAssertTrue(vcf.left == kRootCategory, nil);
                STAssertTrue(vcf.right == 14, nil);
                STAssertTrue(vcf.depth == 0, nil);
                break;

            case 2:
                STAssertTrue(vcf.left == 4, nil);
                STAssertTrue(vcf.right == 9, nil);
                STAssertTrue(vcf.depth == 3, nil);
                break;

            case 3:
                STAssertTrue(vcf.left == 5, nil);
                STAssertTrue(vcf.right == 6, nil);
                STAssertTrue(vcf.depth == 4, nil);
                break;

            case 4:
                STAssertTrue(vcf.left == 7, nil);
                STAssertTrue(vcf.right == 8, nil);
                STAssertTrue(vcf.depth == 4, nil);
                break;

            case 5:
                STAssertTrue(vcf.left == 2, nil);
                STAssertTrue(vcf.right == 11, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 6:
                STAssertTrue(vcf.left == 3, nil);
                STAssertTrue(vcf.right == 10, nil);
                STAssertTrue(vcf.depth == 2, nil);
                break;
        }
    }

    HCategory *newA = [self.categoryModel categoryWithCategoryID:2];
    HCategory *root = [self.categoryModel categoryWithCategoryID:kRootCategory];

    // move newA to root
    [self.categoryModel moveCategory:newA toCategory:root];

    for (HCategory *vcf in [self.categoryModel listCategory]) {
        switch (vcf.identify) {
            case 1:
                STAssertTrue(vcf.left == kRootCategory, nil);
                STAssertTrue(vcf.right == 14, nil);
                STAssertTrue(vcf.depth == 0, nil);
                break;

            case 2:
                STAssertTrue(vcf.left == 8, nil);
                STAssertTrue(vcf.right == 13, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 3:
                STAssertTrue(vcf.left == 9, nil);
                STAssertTrue(vcf.right == 10, nil);
                STAssertTrue(vcf.depth == 2, nil);
                break;

            case 4:
                STAssertTrue(vcf.left == 11, nil);
                STAssertTrue(vcf.right == 12, nil);
                STAssertTrue(vcf.depth == 2, nil);
                break;

            case 5:
                STAssertTrue(vcf.left == 2, nil);
                STAssertTrue(vcf.right == 5, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 6:
                STAssertTrue(vcf.left == 3, nil);
                STAssertTrue(vcf.right == 4, nil);
                STAssertTrue(vcf.depth == 2, nil);
                break;
        }
    }
}

- (void)testMoveHard_Right2Left {
    [self cleanTree];

    [self.categoryModel insertCategoryWithName:@"A" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"B" atCategoryID:2];
    [self.categoryModel insertCategoryWithName:@"C" atCategoryID:2];
    [self.categoryModel insertCategoryWithName:@"D" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"E" atCategoryID:5];
    [self.categoryModel insertCategoryWithName:@"F" atCategoryID:kRootCategory];

    HCategory *c = [self.categoryModel categoryWithCategoryID:4];
    HCategory *d = [self.categoryModel categoryWithCategoryID:5];

    [self.categoryModel moveCategory:d toCategory:c];

    for (HCategory *vcf in [self.categoryModel listCategory]) {
        switch (vcf.identify) {
            case 1:
                STAssertTrue(vcf.left == kRootCategory, nil);
                STAssertTrue(vcf.right == 14, nil);
                STAssertTrue(vcf.depth == 0, nil);
                break;

            case 2:
                STAssertTrue(vcf.left == 2, nil);
                STAssertTrue(vcf.right == 11, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 3:
                STAssertTrue(vcf.left == 3, nil);
                STAssertTrue(vcf.right == 4, nil);
                STAssertTrue(vcf.depth == 2, nil);
                break;

            case 4:
                STAssertTrue(vcf.left == 5, nil);
                STAssertTrue(vcf.right == 10, nil);
                STAssertTrue(vcf.depth == 2, nil);
                break;

            case 5:
                STAssertTrue(vcf.left == 6, nil);
                STAssertTrue(vcf.right == 9, nil);
                STAssertTrue(vcf.depth == 3, nil);
                break;

            case 6:
                STAssertTrue(vcf.left == 7, nil);
                STAssertTrue(vcf.right == 8, nil);
                STAssertTrue(vcf.depth == 4, nil);
                break;
            case 7:
                STAssertTrue(vcf.left == 12, nil);
                STAssertTrue(vcf.right == 13, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;
        }
    }
}

- (void)testMoveVeryHardWay {
    [self cleanTree];

    [self.categoryModel insertCategoryWithName:@"A" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"B" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"F" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"J" atCategoryID:kRootCategory];

    [self.categoryModel insertCategoryWithName:@"C" atCategoryID:3];
    [self.categoryModel insertCategoryWithName:@"G" atCategoryID:4];

    [self.categoryModel insertCategoryWithName:@"D" atCategoryID:6];
    [self.categoryModel insertCategoryWithName:@"E" atCategoryID:6];

    [self.categoryModel insertCategoryWithName:@"H" atCategoryID:7];
    [self.categoryModel insertCategoryWithName:@"I" atCategoryID:7];

    HCategory *g = [self.categoryModel categoryWithCategoryID:7];
    HCategory *e = [self.categoryModel categoryWithCategoryID:9];
    [self.categoryModel moveCategory:g toCategory:e];

    for (HCategory *vcf in [self.categoryModel listCategory]) {
        switch (vcf.identify) {
            case 1:
                STAssertTrue(vcf.left == kRootCategory, nil);
                STAssertTrue(vcf.right == 22, nil);
                STAssertTrue(vcf.depth == 0, nil);
                break;

            case 2:
                STAssertTrue(vcf.left == 2, nil);
                STAssertTrue(vcf.right == 3, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 3:
                STAssertTrue(vcf.left == 4, nil);
                STAssertTrue(vcf.right == 17, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 4:
                STAssertTrue(vcf.left == 18, nil);
                STAssertTrue(vcf.right == 19, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 5:
                STAssertTrue(vcf.left == 20, nil);
                STAssertTrue(vcf.right == 21, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;

            case 6:
                STAssertTrue(vcf.left == 5, nil);
                STAssertTrue(vcf.right == 16, nil);
                STAssertTrue(vcf.depth == 2, nil);
                break;
            case 7:
                STAssertTrue(vcf.left == 9, nil);
                STAssertTrue(vcf.right == 14, nil);
                STAssertTrue(vcf.depth == 4, nil);
                break;
            case 8:
                STAssertTrue(vcf.left == 6, nil);
                STAssertTrue(vcf.right == 7, nil);
                STAssertTrue(vcf.depth == 3, nil);
                break;
            case 9:
                STAssertTrue(vcf.left == 8, nil);
                STAssertTrue(vcf.right == 15, nil);
                STAssertTrue(vcf.depth == 3, nil);
                break;
            case 10:
                STAssertTrue(vcf.left == 10, nil);
                STAssertTrue(vcf.right == 11, nil);
                STAssertTrue(vcf.depth == 5, nil);
                break;
            case 11:
                STAssertTrue(vcf.left == 12, nil);
                STAssertTrue(vcf.right == 13, nil);
                STAssertTrue(vcf.depth == 5, nil);
                break;
        }
    }
}

- (void)testListDepth {
    [self cleanTree];

    [self.categoryModel insertCategoryWithName:@"A" atCategoryID:kRootCategory];
    [self.categoryModel insertCategoryWithName:@"B" atCategoryID:2];
    [self.categoryModel insertCategoryWithName:@"C" atCategoryID:kRootCategory];

    NSArray *resultCategories = [self.categoryModel listCategoryWithCategoryID:kRootCategory];
    STAssertNotNil(resultCategories, @"result listCategoryWithCategoryID is null");
    STAssertTrue([resultCategories count] == 2, nil);

    for (HCategory *vcf in resultCategories) {
        switch (vcf.identify) {
            case 2:
                STAssertTrue(vcf.left == 2, nil);
                STAssertTrue(vcf.right == 5, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;
            case 4:
                STAssertTrue(vcf.left == 6, nil);
                STAssertTrue(vcf.right == 7, nil);
                STAssertTrue(vcf.depth == 1, nil);
                break;
        }
    }
}

- (void)testParentCategory {
    [self cleanTree];
    NSInteger insertCategoryID = [self.categoryModel insertCategoryWithName:@"firstNode" atCategoryID:kRootCategory];
    HCategory *parentCategory = [self.categoryModel parentCategoryWithCategoryID:insertCategoryID];
    NSLog(@"%@", parentCategory);
    STAssertTrue(parentCategory.identify == kRootCategory, nil);
    STAssertTrue(parentCategory.left == kRootCategory, nil);
    STAssertTrue(parentCategory.right == 4, nil);
    STAssertTrue([parentCategory.name compare:@"root"] == NSOrderedSame, nil);
}

- (void)testRootNode {
    [self cleanTree];
    [self insertTestData];

    STAssertNotNil([self.categoryModel categoryWithCategoryID:kRootCategory], nil);
}

@end
