//
//  GetProductCategoriesModel.swift
//  ToshalTest
//
//  Created by Tejash Barbhaya on 11/04/24.
//

import Foundation

// MARK: - ProductCategories
struct ProductCategories: Codable {
    let responseStatus: String?
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let bannerImages: [BannerImage]?
    let categories: [Category]?
}

// MARK: - BannerImage
struct BannerImage: Codable {
    let image, linkType: String?
    let link: String?
}

// MARK: - Category
struct Category: Codable, Identifiable {
    var id = UUID()
    
    let categoryID, name, image: String?
    let subCategory: [SubCategory]?

    enum CodingKeys: String, CodingKey {
        case categoryID = "categoryId"
        case name, image, subCategory
    }
}

// MARK: - SubCategory
struct SubCategory: Codable,Identifiable {
    var id = UUID()
    
    let categoryID, subCategory: String?

    enum CodingKeys: String, CodingKey {
        case categoryID = "categoryId"
        case subCategory
    }
}
