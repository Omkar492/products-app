//
//  ProductRouter.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

final class ProductRouter: AppRouterProtocol {

    private weak var navigationController: UINavigationController?
    private let detailBuilder: ProductDetailBuilding

    init(navigationController: UINavigationController, detailBuilder: ProductDetailBuilding) {
        self.navigationController = navigationController
        self.detailBuilder = detailBuilder
    }

    func navigate(to route: AppRoute) {
        switch route {
        case .productDetail(let product):
            let detailViewController = detailBuilder.makeProductDetailViewController(for: product)
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }

    func pop(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool) {
        navigationController?.popToRootViewController(animated: animated)
    }
}
