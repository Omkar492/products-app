//
//  Endpoint.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.url
    }

    var method: HTTPMethod { .get }

    var headers: [String: String] {
        ["Content-Type": "application/json", "Accept": "application/json"]
    }
}
