//
//  FirstViewModel.swift
//  SampleSwiftUI
//
//  Created by Tejash Barbhaya on 11/04/24.
//

import Foundation
import Combine
import UIKit

public class FirstViewModel: NSObject, ObservableObject {
    var apiRequester : APIRequester
    var cancelable: Set<AnyCancellable> = []
    var currentCategory:Category = Category(categoryID: "", name: "", image: "", subCategory:nil)
    
    @Published var isLoading = false
    @Published var productCategories : ProductCategories?
    
    init(apiRequester:APIRequester? = nil) {
        self.apiRequester = apiRequester ?? APIRequester()
        super.init()
    }
    
    public func createNewToken() {
        self.isLoading = true
        let request = APIRouter.CreateNewToken(deviceId: UIDevice.current.identifierForVendor!.uuidString)
        self.apiRequester
            .dispatch(request)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.isLoading = false
                    print("Error fetching data: \(error)")
                case .finished:
                    self.isLoading = false
                    print("Data fetched successfully")
                    
                    //Fetch Product Categories
                    self.getProductCategories()
                }
            } receiveValue: { responseModel in
                print("Data received : \(responseModel)")
            }
            .store(in: &cancelable)
    }
    
    
    public func getProductCategories() {
        self.isLoading = true
        let request = APIRouter.GetProductCategories()
        self.apiRequester
            .dispatch(request)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.isLoading = false
                    print("Error fetching data: \(error)")
                case .finished:
                    self.isLoading = false
                    print("Data fetched successfully")
                    
                }
            } receiveValue: { productCategories in
                print("Data received : \(productCategories)")
                self.productCategories = productCategories
            }
            .store(in: &cancelable)
    }
    
    func refreshImageUrl(_ imageName: String) -> String {
        let urlString = APIConstants.imagePrefixUrl + imageName
        let finalUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return finalUrl
    }
    
}
