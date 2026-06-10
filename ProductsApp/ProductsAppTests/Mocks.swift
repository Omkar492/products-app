//
//  Mocks.swift
//  ProductsAppTests
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit
import Foundation
@testable import ProductsApp

final class MockProductRepository: ProductRepositoryProtocol {

    var stubbedResult: Result<PaginatedResult<Product>, Error> = .success(.empty)
    private(set) var fetchCallCount = 0
    private(set) var capturedPage: Int?
    private(set) var capturedPages: [Int] = []
    private(set) var capturedLimit: Int?
    private(set) var capturedCategory: String?

    func fetchProducts(
        page: Int,
        limit: Int,
        category: String
    ) async throws -> PaginatedResult<Product> {
        fetchCallCount += 1
        capturedPage = page
        capturedPages.append(page)
        capturedLimit = limit
        capturedCategory = category
        return try stubbedResult.get()
    }
}

final class MockNetworkClient: NetworkClientProtocol {

    var stubbedData: (any Decodable)?
    var stubbedError: Error?

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        if let error = stubbedError { throw error }
        guard let data = stubbedData as? T else {
            throw AppError.decodingFailed
        }
        return data
    }
}

final class MockRouter: AppRouterProtocol {

    private(set) var navigatedRoutes: [AppRoute] = []
    private(set) var popCallCount: Int = 0
    private(set) var popToRootCallCount: Int = 0

    var lastRoute: AppRoute? { navigatedRoutes.last }

    func navigate(to route: AppRoute) {
        navigatedRoutes.append(route)
    }

    func pop(animated: Bool) {
        popCallCount += 1
    }

    func popToRoot(animated: Bool) {
        popToRootCallCount += 1
    }
}

final class MockImageLoader: ImageLoaderProtocol {
    func loadImage(from url: URL) async -> UIImage? { nil }
}

final class MockProductDetailBuilder: ProductDetailBuilding {
    func makeProductDetailViewController(for product: Product) -> UIViewController {
        ProductDetailViewController(
            viewModel: ProductDetailViewModel(product: product),
            imageLoader: MockImageLoader()
        )
    }
}

extension PaginatedResult where T == Product {

    static var empty: PaginatedResult<Product> {
        PaginatedResult(
            data: [],
            pagination: PaginationMetaData(
                nextPage: Constants.Pagination.initialPage,
                limit: Constants.Pagination.pageSize,
                total: 0
            )
        )
    }

    static func make(
        items: [Product],
        page: Int = Constants.Pagination.initialPage,
        limit: Int = Constants.Pagination.pageSize,
        total: Int? = nil
    ) -> PaginatedResult<Product> {
        PaginatedResult(
            data: items,
            pagination: PaginationMetaData(
                nextPage: page,
                limit: limit,
                total: total ?? items.count
            )
        )
    }
}

extension Product {

    static func stub(
        id: Int = 1,
        title: String = "Test Product",
        description: String = "A great product",
        category: String = "electronics",
        price: Double = 99.99,
        imageURL: URL? = nil,
        rating: ProductRating? = ProductRating(rate: 4.5, count: 120)
    ) -> Product {
        Product(
            id: id,
            title: title,
            description: description,
            category: category,
            price: price,
            imageURL: imageURL,
            rating: rating
        )
    }
}
