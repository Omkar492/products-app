//
//  ProductRepository.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import Foundation

protocol ProductRepositoryProtocol {
    func fetchProducts(page: Int, limit: Int, category: String) async throws -> PaginatedResult<Product>
}

final class ProductRepository: ProductRepositoryProtocol {

    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func fetchProducts(page: Int, limit: Int, category: String) async throws -> PaginatedResult<Product> {
        let endpoint = ProductEndpoint.products(page: page, limit: limit, category: category)
        return try await networkClient.request(endpoint)
    }
}
