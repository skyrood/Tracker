//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Rodion Kim on 2025/07/09.
//

import Foundation

final class CategoryListViewModel {

    // MARK: - Public Properties
    var categoryListBinding: Binding<[CategoryViewModel]>?
    
    var selectedCategory: TrackerCategory?
    
    // MARK: - Private Properties
    private let trackerCategoryStore: TrackerCategoryStore
    
    private(set) var categories: [CategoryViewModel] = [] {
        didSet {
            categoryListBinding?(categories)
        }
    }
    
    // MARK: - Initializers
    convenience init() {
        let trackerCategoryStore = TrackerCategoryStore.shared
        self.init(trackerCategoryStore: trackerCategoryStore)
    }
    
    init(trackerCategoryStore: TrackerCategoryStore, selectedCategory: TrackerCategory? = nil) {
        self.trackerCategoryStore = trackerCategoryStore
        categories = getCategoriesFromStore()
        self.selectedCategory = selectedCategory
    }
    
    // MARK: - Public Methods
    func addCategory(_ newCategory: TrackerCategory) {
        guard !categories.contains(where: { $0.categoryName == newCategory.name }) else { return }
        categories.append(CategoryViewModel(categoryName: newCategory.name))
        selectedCategory = newCategory
    }
    
    func selectCategory(at index: Int) {
        let tappedCategory = categories[index].category
        if selectedCategory?.name == tappedCategory.name {
            selectedCategory = nil
        } else {
            selectedCategory = tappedCategory
        }
    }
    
    // MARK: - Private Methods
    private func getCategoriesFromStore() -> [CategoryViewModel] {
        return trackerCategoryStore.categories.map {
            CategoryViewModel(categoryName: $0.name)
        }
    }
}
