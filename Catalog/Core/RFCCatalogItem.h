//
//  RFCCatalogItem.h
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/18/21.
//  Copyright © 2021 Regula. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RFCCatalogItemCategory) {
    RFCCatalogItemCategoryBasic,
    RFCCatalogItemCategoryFeature,
    RFCCatalogItemCategoryViewCustomization,
    RFCCatalogItemCategoryOther,
} NS_SWIFT_NAME(CatalogItem.Category);

NS_SWIFT_NAME(CatalogItem)
@interface RFCCatalogItem : NSObject

/// The catalog item title. Required.
@property(readwrite, nonatomic, copy) NSString *title;

/// The example item description. Optional.
@property(readwrite, nonatomic, copy, nullable) NSString *itemDescription;

/// The category for this item.
@property(readwrite, nonatomic, assign) RFCCatalogItemCategory category;

/// The catalog Item may provide custom viewController to show upon selecting.
- (nullable UIViewController *)build;

/// Will be called when the catalog item is selected and there is no build function provided.
- (void)onItemSelectedFrom:(nonnull UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
