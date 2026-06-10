//
//  PaginatedResult.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

struct PaginatedResult<T: Decodable>: Decodable {
    let data: [T]
    let pagination: PaginationMetaData
}

struct PaginationMetaData: Decodable {
    let nextPage: Int
    let limit: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case nextPage = "page", limit, total
    }
}
