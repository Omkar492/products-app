//
//  AppRouter.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

// MARK: – Route enum

enum AppRoute: Equatable {
    case productDetail(Product)
}

// MARK: – Router protocol

protocol AppRouterProtocol: AnyObject {
    /// Navigate to the given route. Always called on the main thread.
    func navigate(to route: AppRoute)

    /// Pop the top view controller from the navigation stack.
    func pop(animated: Bool)

    /// Pop to the root view controller.
    func popToRoot(animated: Bool)
}

// Convenience default so callers can omit `animated:` for the common case.
extension AppRouterProtocol {
    func pop() { pop(animated: true) }
    func popToRoot() { popToRoot(animated: true) }
}
