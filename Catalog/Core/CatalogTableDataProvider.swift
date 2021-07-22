//
//  CatalogDataProvider.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/18/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import Foundation

struct CatalogRow {
    let id: String
    let title: String
    let description: String?
}

struct CatalogSection {
    let title: String
    let category: CatalogItem.Category
    let rows: [CatalogRow]
}

final class CatalogTableDataProvider {
    private lazy var catalogItems: [CatalogItem] = {
        return [
            LivenessDefaultItem(),
            FaceCaptureDefaultItem(),
            MatchFacesRequestItem(),

            LivenessCameraSwitchItem(),
            LivenessAttemptsCountItem(),
            LivenessHintAnimationItem(),
            FaceCaptureCameraPositionItem(),
            FaceCaptureHintAnimationItem(),

            LivenessHintViewAppearanceItem(),
            LivenessHintPositionItem(),
            LivenessHideTorchItem(),
            LivenessToolbarAppearanceItem(),
            LivenessToolbarPositionItem(),
            LivenessToolbarCustomButtonItem(),
            LivenessToolbarCustomColors(),
            LivenessLogoItem(),
            FaceCaptureBackgroundColor(),

            LocalizationHandlerItem(),
            URLRequestInterceptorItem(),
        ]
    }()

    lazy var content: [CatalogSection] = {
        let sections = catalogItems
            .reduce(into: [CatalogItem.Category: [CatalogItem]]()) { (result, item) in
                var items: [CatalogItem] = result[item.category] ?? []
                items.append(item)
                result[item.category] = items
            }

        let mappedSections: [CatalogSection] = sections
            .compactMap { (_, sectionItems: [CatalogItem]) -> CatalogSection? in
                let rows = sectionItems.map { self.mapCatalogItem($0) }
                guard let firstItem = sectionItems.first else { return nil }

                let category = firstItem.category
                let title = mapItemCategory(category)
                return CatalogSection(title: title, category: category, rows: rows)
            }
            .sorted(by: { $0.category.rawValue < $1.category.rawValue })


        return mappedSections
    }()

    func catalogItemForIndexPath(_ indexPath: IndexPath) -> CatalogItem? {
        let row = content[indexPath.section].rows[indexPath.row]
        let result = catalogItems.first(where: { row.id == keyForCatalogItem($0) })
        return result
    }
}

private extension CatalogTableDataProvider {
    func mapCatalogItem(_ item: CatalogItem) -> CatalogRow {
        return CatalogRow(
            id: keyForCatalogItem(item),
            title: item.title,
            description: item.itemDescription
        )
    }

    func keyForCatalogItem(_ item: CatalogItem) -> String {
        return item.title + (item.itemDescription ?? "")
    }

    func mapItemCategory(_ category: CatalogItem.Category) -> String {
        switch category {
        case .basic:
            return "Basic"
        case .feature:
            return "Feature Customization"
        case .viewCustomization:
            return "View Customization"
        case .other:
            return "Other"
        @unknown default:
            return "Undefined"
        }
    }
}
