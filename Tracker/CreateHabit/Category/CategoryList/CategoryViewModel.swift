//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/09.
//

import Foundation

final class CategoryViewModel: Identifiable {

    // MARK: - Public Properties
    let categoryStore = TrackerCategoryStore.shared
    
    let category: TrackerCategory
    
    var categoryName: String {
        return category.name
    }
    
    var categoryNameBinding: Binding<String>? {
        didSet {
            categoryNameBinding?(categoryName)
        }
    }

    // MARK: - Initializers
    init(categoryName: String) {
        do {
            self.category = try categoryStore.getOrCreateCategory(named: categoryName)
        } catch {
            print("Error while fetching category: \(error)")
            self.category = TrackerCategory(name: categoryName, trackers: [])
        }
    }
}
