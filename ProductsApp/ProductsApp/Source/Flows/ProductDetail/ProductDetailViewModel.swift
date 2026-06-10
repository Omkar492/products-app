//
//  ProductDetailViewModel.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import Foundation

final class ProductDetailViewModel {

    private let product: Product

    var navigationTitle: String { product.title }
    var title: String { product.title }
    var descriptionText: String { product.description }
    var imageURL: URL? { product.imageURL }

    var formattedPrice: String {
        ProductFormatter.price(product.price)
    }

    var formattedRating: String {
        ProductFormatter.detailRating(product.rating)
    }

    var categoryBadge: String {
        ProductFormatter.categoryBadge(product.category, uppercase: false)
    }

    init(product: Product) {
        self.product = product
    }
}
