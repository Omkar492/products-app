//
//  ProductCell.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

final class ProductCell: UITableViewCell {

    static let reuseIdentifier = Constants.ProductCell.reuseIdentifier

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = Constants.ProductCell.Layout.containerCornerRadius
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = Constants.ProductCell.Layout.shadowOpacity
        v.layer.shadowOffset = CGSize(width: 0, height: Constants.ProductCell.Layout.shadowOffsetY)
        v.layer.shadowRadius = Constants.ProductCell.Layout.shadowRadius
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.systemGray6
        iv.layer.cornerRadius = Constants.ProductCell.Layout.imageCornerRadius
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let categoryBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductCell.FontSize.badge, weight: .bold)
        l.textColor = .white
        l.backgroundColor = .systemBlue
        l.textAlignment = .center
        l.layer.cornerRadius = Constants.ProductCell.Layout.badgeCornerRadius
        l.clipsToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductCell.FontSize.title, weight: .semibold)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductCell.FontSize.description)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductCell.FontSize.price, weight: .bold)
        l.textColor = .systemBlue
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductCell.FontSize.rating)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    func configure(with product: Product, imageLoader: ImageLoaderProtocol) {
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        priceLabel.text = ProductFormatter.price(product.price)
        categoryBadge.text = ProductFormatter.categoryBadge(product.category, uppercase: true)
        ratingLabel.text = product.rating.map(ProductFormatter.listRating) ?? ""

        productImageView.loadRemoteImage(
            from: product.imageURL,
            using: imageLoader,
            transitionDuration: Constants.Animation.listImageTransition
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.cancelRemoteImageLoad()
        titleLabel.text = nil
        descriptionLabel.text = nil
        priceLabel.text = nil
        ratingLabel.text = nil
        categoryBadge.text = nil
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        [productImageView, categoryBadge, titleLabel,
         descriptionLabel, priceLabel, ratingLabel].forEach {
            containerView.addSubview($0)
        }

        let layout = Constants.ProductCell.Layout.self
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: layout.outerVerticalPadding),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -layout.outerVerticalPadding),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: layout.outerHorizontalPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -layout.outerHorizontalPadding),

            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: layout.innerPadding),
            productImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: layout.imageSize),
            productImageView.heightAnchor.constraint(equalToConstant: layout.imageSize),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: productImageView.topAnchor, constant: -layout.innerPadding),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: productImageView.bottomAnchor, constant: -layout.innerPadding),

            categoryBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: layout.innerPadding),
            categoryBadge.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: layout.innerPadding),
            categoryBadge.heightAnchor.constraint(equalToConstant: layout.badgeHeight),

            titleLabel.topAnchor.constraint(equalTo: categoryBadge.bottomAnchor, constant: layout.textSpacingTight),
            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: layout.innerPadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -layout.innerPadding),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: layout.textSpacingTight),
            descriptionLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: layout.innerPadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -layout.innerPadding),

            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: layout.textSpacingRegular),
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: layout.innerPadding),
            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -layout.innerPadding),

            ratingLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -layout.innerPadding)
        ])
    }
}
