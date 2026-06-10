//
//  ProductListViewState.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

enum ProductListViewState {
    case idle
    case loading
    case loadingMore
    case loaded
    case empty
    case error(AppError)
}
