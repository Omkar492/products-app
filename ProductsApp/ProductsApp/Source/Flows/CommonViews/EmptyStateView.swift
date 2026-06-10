//
//  EmptyStateView.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

final class EmptyStateView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    private func setupUI() {
        backgroundColor = .systemBackground

        let icon = UIImageView(image: UIImage(systemName: Constants.Symbols.emptyTray))
        icon.tintColor = .systemGray3
        icon.contentMode = .scaleAspectFit
        icon.widthAnchor.constraint(equalToConstant: Constants.EmptyState.Layout.iconSize).isActive = true
        icon.heightAnchor.constraint(equalToConstant: Constants.EmptyState.Layout.iconSize).isActive = true

        let title = UILabel()
        title.text = Constants.Copy.emptyTitle
        title.font = .systemFont(ofSize: Constants.Typography.emptyTitleSize, weight: .semibold)
        title.textAlignment = .center

        let subtitle = UILabel()
        subtitle.text = Constants.Copy.emptySubtitle
        subtitle.font = .systemFont(ofSize: Constants.Typography.bodySize)
        subtitle.textColor = .secondaryLabel
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, title, subtitle])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.EmptyState.Layout.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.EmptyState.Layout.horizontalMargin),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.EmptyState.Layout.horizontalMargin)
        ])
    }
}
