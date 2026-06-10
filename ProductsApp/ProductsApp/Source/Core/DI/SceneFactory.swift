//
//  SceneFactory.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

enum SceneFactory {

    static func makeRootNavigationController(container: AppContainer = .shared) -> UINavigationController {
        let navigationController = UINavigationController()
        let router = ProductRouter(
            navigationController: navigationController,
            detailBuilder: container
        )
        let listViewModel = container.makeProductListViewModel(router: router)
        let listViewController = ProductListViewController(
            viewModel: listViewModel,
            imageLoader: container.imageLoader
        )
        navigationController.setViewControllers([listViewController], animated: false)
        return navigationController
    }
}
