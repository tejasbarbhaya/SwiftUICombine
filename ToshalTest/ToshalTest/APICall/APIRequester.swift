//
//  APIRequester.swift
//  SampleSwiftUI
//
//  Created by Tejash Barbhaya on 11/04/24.
//

import Foundation
import Combine
import SwiftUI


struct APIRouter {}
struct APIParameters { }



public struct APIRequester {
    
    var dispatcher: DispatcherProtocol = NetworkDispatcher()
    
    public init(_ dispatcher: DispatcherProtocol? = NetworkDispatcher()) {
        self.dispatcher = dispatcher ?? NetworkDispatcher()
    }
    
    func dispatch<R: MNCRequest>(_ request: R) -> AnyPublisher<R.ReturnType, APIError> {
        guard let urlRequest = request.asURLRequest() else {
            return Fail(outputType: R.ReturnType.self, failure: APIError.badRequest).eraseToAnyPublisher()
        }
        typealias RequestPublisher = AnyPublisher<R.ReturnType, APIError>
        let requestPublisher: RequestPublisher = dispatcher.dispatch(request: urlRequest)
        return requestPublisher.eraseToAnyPublisher()
    }
}



enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

public enum APIError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError( _ description: String)
    case urlSessionFailed(_ error: URLError)
    case timeOut
    case unknownError
}

extension Encodable {
    var asDictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }

        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}

protocol MNCRequest {
    var urlPath: String { get }
    var method: HTTPMethod { get }
    var body: [String: Any]? { get }
    var queryParams: [String: Any]? { get }
    var headers: [String: String]? { get }
    associatedtype ReturnType: Codable
}

extension MNCRequest {
    
    var method: HTTPMethod { return .get }
    var contentType: String { return "application/json" }
    var queryParams: [String: Any]? { return nil }
    var body: [String: Any]? { return nil }
    var headers: [String: String]? { return nil }
    
    private func requestBodyFrom(params: [String: Any]?) -> Data? {
        guard let params = params else { return nil }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) else {
            return nil
        }
        
        
        return httpBody
    }
    
    func addQueryItems(queryParams: [String: Any]?) -> [URLQueryItem]? {
        guard let queryParams = queryParams else {
            return nil
        }
        return queryParams.map({URLQueryItem(name: $0.key, value: "\($0.value)")})
    }
    
    func asURLRequest() -> URLRequest? {
        guard let url = URL(string: urlPath) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = requestBodyFrom(params: body)
        
        //let headers = self.headers ?? [:]
        //request.allHTTPHeaderFields = headers
        let defaults = UserDefaults.standard
        guard let authTokn = defaults.value(forKey: "authToken") else {
            return request
        }
        request.setValue((authTokn as! String),forHTTPHeaderField:"Authentication")
        
        return request
    }
}


public protocol DispatcherProtocol {
    func dispatch<ReturnType: Codable>(request: URLRequest) -> AnyPublisher<ReturnType, APIError>
}

public struct NetworkDispatcher: DispatcherProtocol {
    let urlSession: URLSession!
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    /// Dispatches an URLRequest and returns a publisher
    /// - Parameter request: URLRequest
    /// - Returns: A publisher with the provided decoded data or an error
    public func dispatch<ReturnType: Codable>(request: URLRequest) -> AnyPublisher<ReturnType, APIError> {
        print("[\(request.httpMethod?.uppercased() ?? "")] '\(request.url!)'")
        return urlSession
            .dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .default))
            // Map on Request response
            .tryMap({ data, response in
                
                // If the response is invalid, throw an error
                guard let response = response as? HTTPURLResponse else {
                    throw httpError(0, data)
                }
                
                //Log Request result
                print("[\(response.statusCode)] '\(request.url!)'")
                
                if let authToken = response.value(forHTTPHeaderField: "authentication") {
                    print("authToken = [\(authToken)]")
                    let defaults = UserDefaults.standard
                    defaults.set(authToken, forKey: "authToken")
                }
                
                if !(200...299).contains(response.statusCode) {
                    throw httpError(response.statusCode, data)
                }
                // Return Response data
                return data
            })
            .receive(on: DispatchQueue.main)
            .decode(type: ReturnType.self, decoder: JSONDecoder())
            .mapError { error in
                return handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    private func httpError(_ statusCode: Int, _ data:Data) -> APIError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
    
    private func handleError(_ error: Error) -> APIError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError(error.localizedDescription)
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as APIError:
            return error
        default:
            return .unknownError
        }
    }
}

