//
//  ErrorView.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

final class ErrorView: UIView {

    var onRetry: (() -> Void)?

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemOrange
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ErrorView.FontSize.title, weight: .semibold)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: Constants.ErrorView.FontSize.message)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = Constants.Copy.retryButtonTitle
        config.image = UIImage(systemName: Constants.Symbols.retry)
        config.imagePadding = Constants.ErrorView.Layout.retryImagePadding
        config.cornerStyle = .capsule
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    func configure(for error: AppError) {
        if error.isNetworkError {
            iconImageView.image = UIImage(systemName: Constants.Symbols.wifiSlash)
            iconImageView.tintColor = .systemOrange
            titleLabel.text = Constants.Copy.errorNetworkTitle
        } else {
            iconImageView.image = UIImage(systemName: Constants.Symbols.warning)
            iconImageView.tintColor = .systemRed
            titleLabel.text = Constants.Copy.errorGenericTitle
        }
        messageLabel.text = error.errorDescription
    }

    @objc private func retryTapped() {
        onRetry?()
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        let stack = UIStackView(
            arrangedSubviews: [iconImageView, titleLabel, messageLabel, retryButton]
        )
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.ErrorView.Layout.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.ErrorView.Layout.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.ErrorView.Layout.iconSize),

            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.ErrorView.Layout.horizontalMargin),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.ErrorView.Layout.horizontalMargin)
        ])
    }
}
