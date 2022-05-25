//
//  CountRequest.swift
//  PoCountess
//
//  Created by Arnaud Joubay on 11/05/2022.
//

import CoreData
import SwiftUI

@MainActor
class CountAPIKey: ObservableObject {
    @Published var value: Int64? = nil
    @Published var info: Response.Info? = nil
    @Published var error: RequestError? = nil
    
    enum Endpoint: String {
        case create, get, hit, info, set, update
        
        var baseURL: String {
            return "https://api.countapi.xyz/\(rawValue)"
        }
    }
    
    typealias Params = [String: Any]
    
    struct Response {
        struct Value: Codable {
            var value: Int64
        }
        
        struct Info: Codable {
            var namespace: String
            var key: String
            var ttl: Int
            var value: Int64
            var resetable: Bool
            var updateUpperbound: Int
            var updateLowerbound: Int
            var created: Int
            
            var daysToLive: Int { ttl / 1000 / 3600 / 24 }
            
            var createdAt: Date {
                Date(timeIntervalSince1970: TimeInterval(created / 1000))
            }
            
            private enum CodingKeys: String, CodingKey {
                case namespace
                case key
                case ttl
                case value
                case resetable = "enable_reset"
                case updateUpperbound = "update_upperbound"
                case updateLowerbound = "update_lowerbound"
                case created
            }
        }
    }
    
    enum RequestError: Error, LocalizedError {
        case requestError(Error)
        case invalidPathSegment
        case invalidURL
        case responseError
        case statusCode(Int)
        case decodingError(Error)
        
        public var errorDescription: String? {
            switch self {
            case .requestError(let error):
                return NSLocalizedString("Request error \(error)", comment: "")
            case .invalidPathSegment:
                return NSLocalizedString("Namespaces and Keys must have between 3 and 64 characters, no space (allowed separators: ._-)", comment: "")
            case .invalidURL:
                return NSLocalizedString("Invalid URL", comment: "")
            case .responseError:
                return NSLocalizedString("HTTPURLResponse error", comment: "")
            case .statusCode(let code):
                return NSLocalizedString("Countapi replied with status code \(code)", comment: "")
            case .decodingError(let error):
                return NSLocalizedString("Error decoding the JSON response: \(error)", comment: "")
            }
        }
    }
    
    @ObservedObject var counter: Counter
    
    internal init(_ counter: Counter) {
        self.counter = counter
    }
    
    var isLoading: Bool {
        value == nil && error == nil
    }
    
    static let pathSegmentPattern = #"^[A-Za-z0-9_\-.]{3,64}$"#
    
    func validate() -> Bool {
        guard counter.domain?.namespace?.range(
            of: Self.pathSegmentPattern,
            options: .regularExpression
        ) != nil else {
            return false
        }
        return counter.key?.range(
            of: Self.pathSegmentPattern,
            options: .regularExpression) != nil
    }
    
    /// Creates a key for the given Counter
    /// - Parameters:
    ///   - resetable: Allows the key to be resetted with /set
    ///   - context: A context to save the returned value upon creation
    func create(resetable: Bool = true, context: NSManagedObjectContext? = nil) async {
        guard let namespace = counter.domain?.namespace,
              let key = counter.key,
              validate()
        else {
            self.error = RequestError.invalidPathSegment
            return
        }
        
        var params: Params = ["namespace": "\(namespace)", "key": "\(key)"]
        if resetable {
            params["enable_reset"] = 1
        }
        
        await fetch(.create, params: params, context: context)
    }
    
    /// Fetch the key value for the given Counter
    /// - Parameter context: A context to save the returned value upon creation
    func get(context: NSManagedObjectContext? = nil) async {
        await fetch(.get, context: context)
    }
    
    /// Hits the key for the given Counter
    /// - Parameter context: A context to save the returned value upon creation
    func hit(context: NSManagedObjectContext? = nil) async {
        await fetch(.hit, context: context)
    }
    
    /// Hits the key for the given Counter
    /// - Parameter context: A context to save the returned value upon creation
    func info(context: NSManagedObjectContext? = nil) async {
        await fetch(.info, context: context)
    }

    /// Fetch the key value for the given Counter
    /// - Parameter context: A context to save the returned value upon creation
    private func fetch(_ endpoint: Endpoint, params: Params? = nil, context: NSManagedObjectContext? = nil) async {
        value = nil
        error = nil
        do {
            let urlString = try urlString(for: endpoint, params: params)
            guard let url = URL(string: urlString) else {
                throw RequestError.invalidURL
            }
            
            let (data, sessionResponse) = try await URLSession.shared.data(from: url)
            
            guard let response = sessionResponse as? HTTPURLResponse else {
                throw RequestError.responseError
            }
            
            guard response.statusCode == 200 else {
                throw RequestError.statusCode(response.statusCode)
            }

            do {
                var fetchedValue: Int64
                if endpoint == .info {
                    let decodedResponse = try JSONDecoder().decode(Response.Info.self, from: data)
                    fetchedValue = decodedResponse.value
                    self.info = decodedResponse
                } else {
                    let decodedResponse = try JSONDecoder().decode(Response.Value.self, from: data)
                    fetchedValue = decodedResponse.value
                }
                self.value = fetchedValue
                if let context = context {
                    try saveValue(fetchedValue, context: context)
                }
            } catch let error {
                throw RequestError.decodingError(error)
            }
        } catch let error {
            if let error = error as? RequestError {
                self.error = error
            } else {
                self.error = RequestError.requestError(error)
            }
        }
    }
    
    private func urlString(for endpoint: Endpoint, params: Params? = nil) throws -> String {
        var url = ""
        
        switch endpoint {
        case .create:
            url += endpoint.baseURL
        default:
            guard let namespace = counter.domain?.namespace,
                  let key = counter.key,
                  validate()
            else {
                throw RequestError.invalidPathSegment
            }
            url += endpoint.baseURL + "/\(namespace)/\(key)"
        }
        
        guard let params = params else {
            return url
        }
        
        let joinedParams = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        
        return [url, joinedParams].joined(separator: "?")
    }
    
    private func saveValue(_ value: Int64, context: NSManagedObjectContext) throws {
        let pastValue = PastValue(context: context)
        pastValue.fetchedAt = Date()
        pastValue.value = value
        self.counter.addToPastValues(pastValue)
        try context.saveIfChanges()
    }
}
