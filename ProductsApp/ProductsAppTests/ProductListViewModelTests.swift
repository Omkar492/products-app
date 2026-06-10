//
//  ProductListViewModelTests.swift
//  ProductsAppTests
//
//  Created by Omkar Chougule on 09/06/26.
//

import XCTest
@testable import ProductsApp

@MainActor
final class ProductListViewModelTests: XCTestCase {

    private var mockRepository: MockProductRepository!
    private var mockRouter: MockRouter!
    private var sut: ProductListViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockProductRepository()
        mockRouter = MockRouter()
        sut = ProductListViewModel(repository: mockRepository, router: mockRouter)
    }

    override func tearDown() {
        sut = nil
        mockRouter = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_initialState_isIdle() {
        XCTAssertEqual(sut.products.count, 0)
        XCTAssertTrue(sut.hasMorePages)
        if case .idle = sut.state { } else {
            XCTFail("Expected .idle, got \(sut.state)")
        }
    }

    func test_loadInitial_withProducts_setsLoadedStateAndPopulatesProducts() async {
        let products = [Product.stub(id: 1), Product.stub(id: 2)]
        mockRepository.stubbedResult = .success(.make(items: products, page: 1))

        await performLoadInitial()

        XCTAssertEqual(sut.products.count, 2)
        XCTAssertEqual(sut.products[0].id, 1)
        XCTAssertEqual(sut.products[1].id, 2)
        if case .loaded = sut.state { } else {
            XCTFail("Expected .loaded, got \(sut.state)")
        }
        XCTAssertTrue(sut.hasMorePages)
    }

    func test_loadInitial_alwaysStartsFromPageZero() async {
        mockRepository.stubbedResult = .success(.empty)
        await performLoadInitial()

        XCTAssertEqual(mockRepository.capturedPage, Constants.Pagination.initialPage)
    }

    func test_loadInitial_resetsExistingProducts() async {
        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 1)], page: 1))
        await performLoadInitial()

        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 99)], page: 0))
        await performLoadInitial()

        XCTAssertEqual(sut.products.count, 1)
        XCTAssertEqual(sut.products[0].id, 99)
    }

    func test_loadInitial_withEmptyResponse_setsEmptyState() async {
        mockRepository.stubbedResult = .success(.empty)
        await performLoadInitial()

        if case .empty = sut.state { } else {
            XCTFail("Expected .empty, got \(sut.state)")
        }
        XCTAssertTrue(sut.products.isEmpty)
    }

    func test_loadInitial_withNoInternet_setsNetworkError() async {
        mockRepository.stubbedResult = .failure(AppError.noInternetConnection)
        await performLoadInitial()

        guard case .error(let appError) = sut.state else {
            XCTFail("Expected .error, got \(sut.state)"); return
        }
        XCTAssertTrue(appError.isNetworkError)
    }

    func test_loadInitial_withServerError_setsServerError() async {
        mockRepository.stubbedResult = .failure(AppError.serverError(statusCode: 500))
        await performLoadInitial()

        guard case .error(let appError) = sut.state else {
            XCTFail("Expected .error, got \(sut.state)"); return
        }
        XCTAssertEqual(appError, AppError.serverError(statusCode: 500))
    }

    func test_loadNextPage_appendsNewProducts_whenLastRowReached() async {
        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 1), Product.stub(id: 2)], page: 1))
        await performLoadInitial()

        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 3), Product.stub(id: 4)], page: 1))
        await performLoadNextPage(at: 1)

        XCTAssertEqual(sut.products.count, 4)
        XCTAssertFalse(sut.hasMorePages)
    }

    func test_loadNextPage_doesNotFire_whenNotLastRow() async {
        mockRepository.stubbedResult = .success(.make(
            items: [Product.stub(id: 1), Product.stub(id: 2), Product.stub(id: 3)],
            page: 1
        ))
        await performLoadInitial()

        let countBefore = mockRepository.fetchCallCount
        sut.loadNextPageIfNeeded(at: 0)
        await Task.yield()

        XCTAssertEqual(mockRepository.fetchCallCount, countBefore)
    }

    func test_loadNextPage_doesNotFire_whenNoMorePages() async {
        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 1)], page: 0))
        await performLoadInitial()
        XCTAssertFalse(sut.hasMorePages)

        let countBefore = mockRepository.fetchCallCount
        sut.loadNextPageIfNeeded(at: 0)
        await Task.yield()

        XCTAssertEqual(mockRepository.fetchCallCount, countBefore)
    }

    func test_pagination_requestsCorrectPageNumbers() async {
        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 1)], page: 1))
        await performLoadInitial()
        XCTAssertEqual(mockRepository.capturedPages, [0])

        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 2)], page: 1))
        await performLoadNextPage(at: 0)

        XCTAssertEqual(mockRepository.capturedPages, [0, 1])
    }

    func test_retry_afterError_loadsSuccessfully() async {
        mockRepository.stubbedResult = .failure(AppError.noInternetConnection)
        await performLoadInitial()
        guard case .error = sut.state else { XCTFail(); return }

        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 1)], page: 0))

        let retryExpectation = expectation(description: "retry")
        let delegate = SpyDelegate()
        delegate.onFetchComplete = { retryExpectation.fulfill() }
        sut.delegate = delegate

        sut.retry()
        await fulfillment(of: [retryExpectation], timeout: 1.0)

        XCTAssertEqual(sut.products.count, 1)
        if case .loaded = sut.state { } else {
            XCTFail("Expected .loaded after retry, got \(sut.state)")
        }
    }

    func test_didSelectProduct_navigatesToProductDetail() async {
        mockRepository.stubbedResult = .success(.make(
            items: [Product.stub(id: 10), Product.stub(id: 20)],
            page: 0
        ))
        await performLoadInitial()

        sut.didSelectProduct(at: 1)

        XCTAssertEqual(mockRouter.navigatedRoutes.count, 1)
        if case .productDetail(let product) = mockRouter.lastRoute {
            XCTAssertEqual(product.id, 20)
        } else {
            XCTFail("Expected .productDetail route")
        }
    }

    func test_didSelectProduct_withOutOfBoundsIndex_doesNotNavigate() async {
        mockRepository.stubbedResult = .success(.make(items: [Product.stub(id: 1)], page: 0))
        await performLoadInitial()

        sut.didSelectProduct(at: 99)

        XCTAssertTrue(mockRouter.navigatedRoutes.isEmpty)
    }

    func test_didSelectProduct_navigatesCorrectProductForEachRow() async {
        let products = (0..<5).map { Product.stub(id: $0, title: "Product \($0)") }
        mockRepository.stubbedResult = .success(.make(items: products, page: 0))
        await performLoadInitial()

        for (row, product) in products.enumerated() {
            sut.didSelectProduct(at: row)
            XCTAssertEqual(mockRouter.lastRoute, .productDetail(product))
        }
        XCTAssertEqual(mockRouter.navigatedRoutes.count, products.count)
    }

    func test_delegate_receivesStateChangeCallback() async {
        let delegate = SpyDelegate()
        sut.delegate = delegate

        mockRepository.stubbedResult = .success(.make(items: [Product.stub()], page: 0))
        await performLoadInitial(using: delegate)

        XCTAssertFalse(delegate.receivedStates.isEmpty)
        XCTAssertTrue(delegate.receivedStates.contains { if case .loaded = $0 { return true }; return false })
    }

    func test_delegate_receivesInsertedRows_forPagination() async {
        let delegate = SpyDelegate()
        sut.delegate = delegate

        mockRepository.stubbedResult = .success(.make(items: (0..<5).map { Product.stub(id: $0) }, page: 1))
        await performLoadInitial(using: delegate)

        mockRepository.stubbedResult = .success(.make(items: (5..<10).map { Product.stub(id: $0) }, page: 1))
        await performLoadNextPage(at: 4, using: delegate)

        let lastUpdate = delegate.receivedUpdates.last
        XCTAssertEqual(lastUpdate?.insertedRows.map { $0 }, [5, 6, 7, 8, 9])
        XCTAssertEqual(lastUpdate?.isInitialLoad, false)
    }

    // MARK: – Helpers

    private func performLoadInitial(using delegate: SpyDelegate? = nil) async {
        let spy = delegate ?? SpyDelegate()
        if delegate == nil { sut.delegate = spy }

        let expectation = expectation(description: "loadInitial")
        spy.onFetchComplete = { expectation.fulfill() }

        sut.loadInitial()
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    private func performLoadNextPage(at row: Int, using delegate: SpyDelegate? = nil) async {
        let spy = delegate ?? SpyDelegate()
        if delegate == nil { sut.delegate = spy }

        let expectation = expectation(description: "loadNextPage")
        spy.onFetchComplete = { expectation.fulfill() }

        sut.loadNextPageIfNeeded(at: row)
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}

private final class SpyDelegate: ProductListViewModelDelegate {
    struct ProductUpdate {
        let insertedRows: Range<Int>
        let isInitialLoad: Bool
    }

    var receivedStates: [ProductListViewState] = []
    var receivedUpdates: [ProductUpdate] = []
    var onFetchComplete: (() -> Void)?

    func viewModelDidChangeState(_ viewModel: ProductListViewModel, state: ProductListViewState) {
        receivedStates.append(state)
        switch state {
        case .loaded, .empty, .error:
            onFetchComplete?()
            onFetchComplete = nil
        default:
            break
        }
    }

    func viewModelDidUpdateProducts(
        _ viewModel: ProductListViewModel,
        insertedRows: Range<Int>,
        isInitialLoad: Bool
    ) {
        receivedUpdates.append(ProductUpdate(insertedRows: insertedRows, isInitialLoad: isInitialLoad))
    }
}
