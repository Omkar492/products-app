//
//  ProductRepositoryTests.swift
//  ProductsAppTests
//
//  Created by Omkar Chougule on 09/06/26.
//

import XCTest
@testable import ProductsApp

final class ProductRepositoryTests: XCTestCase {

    private var mockNetworkClient: MockNetworkClient!
    private var sut: ProductRepository!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        sut = ProductRepository(networkClient: mockNetworkClient)
    }

    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        super.tearDown()
    }

    // MARK: – Success paths

    func test_fetchProducts_returnsCorrectNumberOfItems() async throws {
        let response = makeResponse(productCount: 5, total: 50, page: 0, limit: 10)
        mockNetworkClient.stubbedData = response

        let result = try await sut.fetchProducts(page: 0, limit: 10, category: "electronics")

        XCTAssertEqual(result.data.count, 5)
        XCTAssertEqual(result.pagination.total, 50)
    }

    func test_fetchProducts_mapsNextPageCorrectly() async throws {
        let response = makeResponse(productCount: 10, total: 30, page: 1, limit: 10)
        mockNetworkClient.stubbedData = response

        let result = try await sut.fetchProducts(page: 0, limit: 10, category: "electronics")

        XCTAssertEqual(result.pagination.nextPage, 1)
    }

    func test_fetchProducts_returnsSamePage_onLastPage() async throws {
        let response = makeResponse(productCount: 5, total: 5, page: 0, limit: 10)
        mockNetworkClient.stubbedData = response

        let result = try await sut.fetchProducts(page: 0, limit: 10, category: "electronics")

        XCTAssertEqual(result.pagination.nextPage, 0)
    }

    func test_fetchProducts_mapsDomainEntitiesCorrectly() async throws {
        let response = PaginatedResult<Product>(
            data: [
                Product(
                    id: 7,
                    title: "Laptop X",
                    description: "Fast laptop",
                    category: "laptops",
                    price: 799.0,
                    imageURL: URL(string: "https://example.com/img.jpg")!,
                    rating: ProductRating(rate: 4.2, count: 88),
                    stock: 20
                )
            ],
            pagination: PaginationMetaData(nextPage: 0, limit: 10, total: 1)
        )
        mockNetworkClient.stubbedData = response

        let result = try await sut.fetchProducts(page: 0, limit: 10, category: "laptops")

        XCTAssertEqual(result.data.first?.id, 7)
        XCTAssertEqual(result.data.first?.title, "Laptop X")
        XCTAssertEqual(result.data.first?.price, 799.0)
        XCTAssertEqual(result.data.first?.rating?.rate, 4.2)
        XCTAssertEqual(result.data.first?.imageURL, URL(string: "https://example.com/img.jpg"))
    }

    // MARK: – Error paths

    func test_fetchProducts_propagatesNoInternetError() async {
        mockNetworkClient.stubbedError = AppError.noInternetConnection

        do {
            _ = try await sut.fetchProducts(page: 0, limit: 10, category: "electronics")
            XCTFail("Expected error to be thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.noInternetConnection)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetchProducts_propagatesServerError() async {
        mockNetworkClient.stubbedError = AppError.serverError(statusCode: 503)

        do {
            _ = try await sut.fetchProducts(page: 0, limit: 10, category: "electronics")
            XCTFail("Expected error to be thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.serverError(statusCode: 503))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetchProducts_propagatesDecodingError() async {
        mockNetworkClient.stubbedError = AppError.decodingFailed

        do {
            _ = try await sut.fetchProducts(page: 0, limit: 10, category: "electronics")
            XCTFail("Expected error to be thrown")
        } catch let error as AppError {
            XCTAssertEqual(error, AppError.decodingFailed)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: – Helpers

    private func makeResponse(
        productCount: Int,
        total: Int,
        page: Int,
        limit: Int
    ) -> PaginatedResult<Product> {
        let products = (0..<productCount).map { i in
            Product(
                id: i,
                title: "Product \(i)",
                description: "Desc",
                category: "electronics",
                price: 9.99,
                imageURL: nil,
                rating: nil,
                stock: nil
            )
        }

        return PaginatedResult(
            data: products,
            pagination: PaginationMetaData(
                nextPage: page,
                limit: limit,
                total: total
            )
        )
    }
}
