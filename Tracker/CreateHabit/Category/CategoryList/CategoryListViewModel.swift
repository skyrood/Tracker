//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/09.
//

import Foundation

final class CategoryListViewModel {
    private let trackerCategoryStore: TrackerCategoryStore
    
    private(set) var categories: [CategoryViewModel] = [] {
        didSet {
            categoryListBinding?(categories)
        }
    }
    
    var categoryListBinding: Binding<[CategoryViewModel]>?
    
    var selectedCategory: TrackerCategory?
    
    convenience init() {
        let trackerCategoryStore = TrackerCategoryStore()
        self.init(trackerCategoryStore: trackerCategoryStore)
    }
    
    init(trackerCategoryStore: TrackerCategoryStore, selectedCategory: TrackerCategory? = nil) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerCategoryStore.delegate = self
        categories = getCategoriesFromStore()
        self.selectedCategory = selectedCategory
        
        print("view model says: categories count: \(categories.count)")
    }
    
    private func getCategoriesFromStore() -> [CategoryViewModel] {
        return trackerCategoryStore.categories.map {
            CategoryViewModel(categoryName: $0.name)
        }
    }
    
    func addCategory(_ newCategory: TrackerCategory) {
        guard !categories.contains(where: { $0.categoryName == newCategory.name }) else { return }
        categories.append(CategoryViewModel(categoryName: newCategory.name))
        selectedCategory = newCategory
    }
}

extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore) {
        categories = getCategoriesFromStore()
    }
}

