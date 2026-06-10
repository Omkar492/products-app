//
//  AppContainer.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

final class AppContainer: ProductDetailBuilding {

    static let shared = AppContainer()

    private let urlSession: URLSession

    private lazy var networkClient: NetworkClientProtocol = NetworkClient(session: urlSession)
    private lazy var productRepository: ProductRepositoryProtocol = ProductRepository(networkClient: networkClient)
    private(set) lazy var imageLoader: ImageLoaderProtocol = ImageLoader(session: urlSession)

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func makeRouter(navigationController: UINavigationController) -> AppRouterProtocol {
        ProductRouter(navigationController: navigationController, detailBuilder: self)
    }

    func makeProductListViewModel(router: AppRouterProtocol) -> ProductListViewModel {
        ProductListViewModel(repository: productRepository, router: router)
    }

    func makeProductDetailViewModel(product: Product) -> ProductDetailViewModel {
        ProductDetailViewModel(product: product)
    }

    // MARK: – ProductDetailBuilding

    func makeProductDetailViewController(for product: Product) -> UIViewController {
        ProductDetailViewController(
            viewModel: makeProductDetailViewModel(product: product),
            imageLoader: imageLoader
        )
    }
}
