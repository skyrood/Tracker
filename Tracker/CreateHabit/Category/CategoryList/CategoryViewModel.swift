//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/09.
//

import Foundation

final class CategoryViewModel: Identifiable {
    let categoryStore = TrackerCategoryStore()
    
    let category: TrackerCategory
    
    var categoryName: String {
        return category.name
    }
    
    init(categoryName: String) {
        do {
            self.category = try categoryStore.getOrCreateCategory(named: categoryName)
        } catch {
            print("Error while fetching category: \(error)")
            self.category = TrackerCategory(name: categoryName, trackers: [])
        }
    }
    
    var categoryNameBinding: Binding<String>? {
        didSet {
            categoryNameBinding?(categoryName)
        }
    }
}
