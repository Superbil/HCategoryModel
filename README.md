## HCategoryModel ##

Managing hierarchical data in iOS. This is impelement [managing hierachial data](http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/) in iOS


## Need library ##

* sqlite
* FMDB


## Use age ##

    more example in HCategoryModelTests.m

### open data path

    self.categoryModel = [[HCategoryModel alloc] initWithDatabasePath:path];

### insert first category

    NSInteger insertCategoryID = [self.categoryModel insertCategoryWithName:@"firstNode" atCategoryID:kRootCategory];

### update category

    NSString *newName = @"this is a new name";
    HCategory *vcf = [self.categoryModel categoryWithCategoryID:2];
    vcf.name = newName;

    // check newVCF
    HCategory *newVcf = [self.categoryModel categoryWithCategoryID:2];

### move category

    HCategory *rootCategory = [self.categoryModel categoryWithCategoryID:kRootCategory];
    HCategory *moveCategory = [self.categoryModel categoryWithCategoryID:3];

    [self.categoryModel moveCategory:moveCategory toCategory:rootCategory];

### list all category from root category

    NSArray *resultCategories = [self.categoryModel listCategoryWithCategoryID:kRootCategory];
    for (HCategory *vcf in resultCategories) {
        // .. each vcf
    }


## License ##

MIT
