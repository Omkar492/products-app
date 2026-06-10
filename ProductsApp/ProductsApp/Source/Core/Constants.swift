//
//  Constants.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

enum Constants {

    // MARK: – API & Network

    enum API {
        static let baseURL = "https://fakeapi.net"
        static let productsPath = "/products"
        static let pageQuery = "page"
        static let limitQuery = "limit"
        static let categoryQuery = "category"
        static let successStatusCodeRange = 200...299
        static let invalidURLError = "Invalid URL for endpoint."
        static let nonHTTPResponseError = "Non-HTTP response received."
    }

    // MARK: – Pagination & Business

    enum Pagination {
        static let pageSize = 10
        static let initialPage = 0
        static let category = "electronics"
        static let tableSection = 0
    }

    // MARK: – Formatting

    enum Formatting {
        static let price = "$%.2f"
        static let listRating = "★ %.1f  (%d)"
        static let detailRating = "%.1f ★  (%d reviews)"
        static let noRating = "No ratings yet"
        static let categoryBadge = "  %@  "
    }

    // MARK: – User-facing copy

    enum Copy {
        static let listTitle = "Electronics"
        static let descriptionSectionTitle = "Description"
        static let emptyTitle = "No Products Found"
        static let emptySubtitle = "There are no products available in this category right now."
        static let errorNetworkTitle = "No Internet Connection"
        static let errorGenericTitle = "Something Went Wrong"
        static let retryButtonTitle = "Retry"
        static let noInternetMessage = "No internet connection. Please check your network settings."
        static let serverErrorMessage = "Server error (code %d). Please try again."
        static let decodingFailedMessage = "Could not read the server response. Please try again."
        static let unknownErrorMessage = "Something went wrong. Please try again."
    }

    // MARK: – SF Symbols

    enum Symbols {
        static let photo = "photo"
        static let emptyTray = "tray"
        static let retry = "arrow.clockwise"
        static let wifiSlash = "wifi.slash"
        static let warning = "exclamationmark.triangle.fill"
    }

    // MARK: – Animation

    enum Animation {
        static let listImageTransition: TimeInterval = 0.2
        static let detailImageTransition: TimeInterval = 0.3
    }

    // MARK: – Shared typography

    enum Typography {
        static let emptyTitleSize: CGFloat = 20
        static let bodySize: CGFloat = 14
        static let sectionHeaderSize: CGFloat = 17
    }

    // MARK: – Shared layout

    enum Layout {
        static let horizontalMargin: CGFloat = 40
        static let contentHorizontalMargin: CGFloat = 20
        static let stackSpacingCompact: CGFloat = 12
        static let stackSpacingRegular: CGFloat = 16
        static let separatorHeight: CGFloat = 0.5
        static let bottomContentInset: CGFloat = 32
    }

    // MARK: – Product list screen

    enum ProductList {
        static let estimatedRowHeight: CGFloat = 120
        static let paginationFooterHeight: CGFloat = 60
    }

    // MARK: – Product cell

    enum ProductCell {
        static let reuseIdentifier = "ProductCell"

        enum Layout {
            static let containerCornerRadius: CGFloat = 14
            static let shadowOpacity: Float = 0.07
            static let shadowOffsetY: CGFloat = 2
            static let shadowRadius: CGFloat = 6
            static let imageCornerRadius: CGFloat = 10
            static let imageSize: CGFloat = 80
            static let badgeHeight: CGFloat = 18
            static let badgeCornerRadius: CGFloat = 8
            static let outerVerticalPadding: CGFloat = 6
            static let outerHorizontalPadding: CGFloat = 16
            static let innerPadding: CGFloat = 12
            static let textSpacingTight: CGFloat = 4
            static let textSpacingRegular: CGFloat = 6
        }

        enum FontSize {
            static let badge: CGFloat = 10
            static let title: CGFloat = 15
            static let description: CGFloat = 12
            static let price: CGFloat = 16
            static let rating: CGFloat = 11
        }
    }

    // MARK: – Product detail screen

    enum ProductDetail {
        enum Layout {
            static let heroImageHeight: CGFloat = 280
            static let badgeHeight: CGFloat = 26
            static let badgeCornerRadius: CGFloat = 10
            static let badgeTopSpacing: CGFloat = 16
            static let titleTopSpacing: CGFloat = 10
            static let priceTopSpacing: CGFloat = 14
            static let separatorTopSpacing: CGFloat = 16
            static let descriptionHeaderTopSpacing: CGFloat = 16
            static let descriptionTopSpacing: CGFloat = 8
        }

        enum FontSize {
            static let badge: CGFloat = 12
            static let title: CGFloat = 22
            static let price: CGFloat = 28
            static let rating: CGFloat = 14
            static let description: CGFloat = 15
        }
    }

    // MARK: – Empty state view

    enum EmptyState {
        enum Layout {
            static let iconSize: CGFloat = 60
            static let stackSpacing = Constants.Layout.stackSpacingCompact
            static let horizontalMargin = Constants.Layout.horizontalMargin
        }
    }

    // MARK: – Error view

    enum ErrorView {
        enum Layout {
            static let iconSize: CGFloat = 64
            static let stackSpacing = Constants.Layout.stackSpacingRegular
            static let horizontalMargin = Constants.Layout.horizontalMargin
            static let retryImagePadding: CGFloat = 6
        }

        enum FontSize {
            static let title = Typography.emptyTitleSize
            static let message = Typography.bodySize
        }
    }
}

// MARK: – Shared formatters

enum ProductFormatter {

    static func price(_ value: Double) -> String {
        String(format: Constants.Formatting.price, value)
    }

    static func listRating(_ rating: ProductRating) -> String {
        String(format: Constants.Formatting.listRating, rating.rate, rating.count)
    }

    static func detailRating(_ rating: ProductRating?) -> String {
        guard let rating else { return Constants.Formatting.noRating }
        return String(format: Constants.Formatting.detailRating, rating.rate, rating.count)
    }

    static func categoryBadge(_ category: String, uppercase: Bool = false) -> String {
        let text = uppercase ? category.uppercased() : category.capitalized
        return String(format: Constants.Formatting.categoryBadge, text)
    }
}
