//
//  Product.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import Foundation

struct Product: Decodable, Equatable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let imageURL: URL?
    let rating: ProductRating?
    let stock: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case price
        case thumbnail
        case rating
        case stock
    }
    
    init(
        id: Int,
        title: String,
        description: String,
        category: String,
        price: Double,
        imageURL: URL?,
        rating: ProductRating?,
        stock: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.price = price
        self.imageURL = imageURL
        self.rating = rating
        self.stock = stock
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(String.self, forKey: .category)
        price = try container.decode(Double.self, forKey: .price)
        rating = try container.decodeIfPresent(ProductRating.self, forKey: .rating)
        stock = try container.decodeIfPresent(Int.self, forKey: .stock)
        
        let thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        imageURL = thumbnail.flatMap { URL(string: $0) }
    }
}

struct ProductRating: Decodable, Equatable {
    let rate: Double
    let count: Int
}
