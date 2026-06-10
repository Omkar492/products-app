//
//  ProductDetailViewController.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

final class ProductDetailViewController: UIViewController {

    private let viewModel: ProductDetailViewModel
    private let imageLoader: ImageLoaderProtocol

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor.systemGray6
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let categoryBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductDetail.FontSize.badge, weight: .bold)
        l.textColor = .white
        l.backgroundColor = .systemBlue
        l.layer.cornerRadius = Constants.ProductDetail.Layout.badgeCornerRadius
        l.clipsToBounds = true
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductDetail.FontSize.title, weight: .bold)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductDetail.FontSize.price, weight: .heavy)
        l.textColor = .systemBlue
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductDetail.FontSize.rating)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let separatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let descriptionHeaderLabel: UILabel = {
        let l = UILabel()
        l.text = Constants.Copy.descriptionSectionTitle
        l.font = .systemFont(ofSize: Constants.Typography.sectionHeaderSize, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ProductDetail.FontSize.description)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    init(viewModel: ProductDetailViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        populateData()
        loadHeroImage()
    }

    private func setupNavigationBar() {
        title = viewModel.navigationTitle
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [heroImageView, categoryBadge, titleLabel,
         priceLabel, ratingLabel, separatorLine,
         descriptionHeaderLabel, descriptionLabel
        ].forEach { contentView.addSubview($0) }

        let margin = Constants.Layout.contentHorizontalMargin
        let layout = Constants.ProductDetail.Layout.self
        let g = contentView

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            heroImageView.topAnchor.constraint(equalTo: g.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: layout.heroImageHeight),

            categoryBadge.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: layout.badgeTopSpacing),
            categoryBadge.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: margin),
            categoryBadge.heightAnchor.constraint(equalToConstant: layout.badgeHeight),

            titleLabel.topAnchor.constraint(equalTo: categoryBadge.bottomAnchor, constant: layout.titleTopSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -margin),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: layout.priceTopSpacing),
            priceLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: margin),

            ratingLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -margin),

            separatorLine.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: layout.separatorTopSpacing),
            separatorLine.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: margin),
            separatorLine.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -margin),
            separatorLine.heightAnchor.constraint(equalToConstant: Constants.Layout.separatorHeight),

            descriptionHeaderLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: layout.descriptionHeaderTopSpacing),
            descriptionHeaderLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: margin),
            descriptionHeaderLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -margin),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionHeaderLabel.bottomAnchor, constant: layout.descriptionTopSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: margin),
            descriptionLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -margin),
            descriptionLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -Constants.Layout.bottomContentInset)
        ])
    }

    private func populateData() {
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.formattedPrice
        ratingLabel.text = viewModel.formattedRating
        descriptionLabel.text = viewModel.descriptionText
        categoryBadge.text = viewModel.categoryBadge
    }

    private func loadHeroImage() {
        heroImageView.loadRemoteImage(
            from: viewModel.imageURL,
            using: imageLoader,
            transitionDuration: Constants.Animation.detailImageTransition
        )
    }
}
