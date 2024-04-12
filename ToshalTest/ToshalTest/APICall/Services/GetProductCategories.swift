//
//  GetProductCategories.swift
//  ToshalTest
//
//  Created by Tejash Barbhaya on 11/04/24.
//

import Foundation

extension APIRouter {
    struct GetProductCategories : MNCRequest {
        typealias ReturnType = ProductCategories
        var urlPath: String = APIConstants.getProductCategories
        var method: HTTPMethod = .get
    }
}
