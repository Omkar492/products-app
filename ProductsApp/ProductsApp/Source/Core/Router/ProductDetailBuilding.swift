//
//  ProductDetailBuilding.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

protocol ProductDetailBuilding: AnyObject {
    func makeProductDetailViewController(for product: Product) -> UIViewController
}
