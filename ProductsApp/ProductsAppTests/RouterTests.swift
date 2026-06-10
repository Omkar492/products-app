//
//  MockRouterTests.swift
//  ProductsAppTests
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit
import XCTest
@testable import ProductsApp

// MARK: – MockRouter behaviour tests

final class MockRouterTests: XCTestCase {

    private var sut: MockRouter!

    override func setUp() {
        super.setUp()
        sut = MockRouter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_navigate_recordsRoute() {
        let product = Product.stub(id: 42)
        sut.navigate(to: .productDetail(product))

        XCTAssertEqual(sut.navigatedRoutes.count, 1)
        XCTAssertEqual(sut.lastRoute, .productDetail(product))
    }

    func test_navigate_recordsMultipleRoutes_inOrder() {
        let p1 = Product.stub(id: 1)
        let p2 = Product.stub(id: 2)
        sut.navigate(to: .productDetail(p1))
        sut.navigate(to: .productDetail(p2))

        XCTAssertEqual(sut.navigatedRoutes.count, 2)
        XCTAssertEqual(sut.navigatedRoutes[0], .productDetail(p1))
        XCTAssertEqual(sut.navigatedRoutes[1], .productDetail(p2))
    }

    func test_pop_incrementsCounter() {
        sut.pop(animated: true)
        sut.pop(animated: false)

        XCTAssertEqual(sut.popCallCount, 2)
    }

    func test_popToRoot_incrementsCounter() {
        sut.popToRoot(animated: true)

        XCTAssertEqual(sut.popToRootCallCount, 1)
    }

    func test_initialState_hasNoRecordedCalls() {
        XCTAssertTrue(sut.navigatedRoutes.isEmpty)
        XCTAssertEqual(sut.popCallCount, 0)
        XCTAssertEqual(sut.popToRootCallCount, 0)
        XCTAssertNil(sut.lastRoute)
    }
}

// MARK: – AppRoute Equatable tests

final class AppRouteEquatableTests: XCTestCase {

    func test_productDetailRoute_isEqualWhenSameProduct() {
        let product = Product.stub(id: 7)
        XCTAssertEqual(AppRoute.productDetail(product), AppRoute.productDetail(product))
    }

    func test_productDetailRoute_isNotEqualWhenDifferentProduct() {
        let p1 = Product.stub(id: 1)
        let p2 = Product.stub(id: 2)
        XCTAssertNotEqual(AppRoute.productDetail(p1), AppRoute.productDetail(p2))
    }
}

// MARK: – ProductRouter tests

final class ProductRouterTests: XCTestCase {

    private var spyNavController: SpyNavigationController!
    private var sut: ProductRouter!

    override func setUp() {
        super.setUp()
        spyNavController = SpyNavigationController()
        sut = ProductRouter(navigationController: spyNavController, detailBuilder: MockProductDetailBuilder())
    }

    override func tearDown() {
        sut = nil
        spyNavController = nil
        super.tearDown()
    }

    func test_navigate_productDetail_pushesProductDetailViewController() {
        let product = Product.stub(id: 99, title: "Router Test Product")
        sut.navigate(to: .productDetail(product))

        XCTAssertEqual(spyNavController.pushedViewControllers.count, 1)
        XCTAssertTrue(
            spyNavController.pushedViewControllers.first is ProductDetailViewController,
            "Expected ProductDetailViewController, got \(String(describing: spyNavController.pushedViewControllers.first))"
        )
    }

    func test_navigate_productDetail_pushesWithAnimation() {
        sut.navigate(to: .productDetail(Product.stub()))

        XCTAssertTrue(spyNavController.lastPushWasAnimated ?? false)
    }

    func test_pop_callsPopOnNavigationController() {
        sut.pop(animated: true)

        XCTAssertEqual(spyNavController.popCallCount, 1)
    }

    func test_popToRoot_callsPopToRootOnNavigationController() {
        sut.popToRoot(animated: false)

        XCTAssertEqual(spyNavController.popToRootCallCount, 1)
    }

    func test_defaultPop_isAnimated() {
        // Uses the extension default: pop() == pop(animated: true)
        sut.pop()
        XCTAssertTrue(spyNavController.lastPopWasAnimated ?? false)
    }
}

// MARK: – SpyNavigationController

/// Intercepts UINavigationController calls so tests never need a UIWindow.
final class SpyNavigationController: UINavigationController {

    private(set) var pushedViewControllers: [UIViewController] = []
    private(set) var lastPushWasAnimated: Bool?
    private(set) var popCallCount = 0
    private(set) var lastPopWasAnimated: Bool?
    private(set) var popToRootCallCount = 0

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
        lastPushWasAnimated = animated
        // Do NOT call super — avoids needing a visible window
    }

    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        popCallCount += 1
        lastPopWasAnimated = animated
        return nil
    }

    @discardableResult
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        popToRootCallCount += 1
        return nil
    }
}
