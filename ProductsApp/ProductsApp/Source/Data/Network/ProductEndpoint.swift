//
//  ProductEndpoint.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import Foundation

enum ProductEndpoint: Endpoint {
    case products(page: Int, limit: Int, category: String)

    var baseURL: String { Constants.API.baseURL }

    var path: String {
        switch self {
        case .products:
            return Constants.API.productsPath
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .products(let page, let limit, let category):
            return [
                URLQueryItem(name: Constants.API.pageQuery, value: "\(page)"),
                URLQueryItem(name: Constants.API.limitQuery, value: "\(limit)"),
                URLQueryItem(name: Constants.API.categoryQuery, value: "\(category)")
            ]
        }
    }
}
