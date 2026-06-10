//
//  UIImageView+RemoteImage.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

extension UIImageView {

    private static var remoteImageURLKey: UInt8 = 0

    private var remoteImageURL: URL? {
        get { objc_getAssociatedObject(self, &Self.remoteImageURLKey) as? URL }
        set { objc_setAssociatedObject(self, &Self.remoteImageURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func loadRemoteImage(
        from url: URL?,
        using imageLoader: ImageLoaderProtocol,
        transitionDuration: TimeInterval = Constants.Animation.listImageTransition
    ) {
        image = nil
        remoteImageURL = url

        guard let url else {
            applyPhotoPlaceholder()
            return
        }

        Task { [weak self] in
            let loadedImage = await imageLoader.loadImage(from: url)
            guard let self, self.remoteImageURL == url else { return }

            await MainActor.run {
                UIView.transition(with: self, duration: transitionDuration, options: .transitionCrossDissolve) {
                    if let loadedImage {
                        self.image = loadedImage
                        self.tintColor = nil
                    } else {
                        self.applyPhotoPlaceholder()
                    }
                }
            }
        }
    }

    func cancelRemoteImageLoad() {
        remoteImageURL = nil
        image = nil
    }

    private func applyPhotoPlaceholder() {
        image = UIImage(systemName: Constants.Symbols.photo)
        tintColor = .systemGray3
    }
}
