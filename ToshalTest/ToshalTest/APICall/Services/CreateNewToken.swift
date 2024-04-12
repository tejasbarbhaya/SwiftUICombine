//
//  CreateNewToken.swift
//  ToshalTest
//
//  Created by Tejash Barbhaya on 11/04/24.
//

import Foundation

extension APIParameters {
    struct CreateNewTokenParams : Encodable {
        var clientId:String
        var clientSecret:String
    }
}

extension APIRouter {
    struct CreateNewToken : MNCRequest {
        typealias ReturnType = ResponseToken
        var urlPath: String = APIConstants.getNewToken
        var method: HTTPMethod = .post
        var body: [String : Any]?
        var queryParams: [String : Any]?
        
        init(deviceId:String) {
            self.urlPath = String(format: urlPath,deviceId)
        }
    }
}
