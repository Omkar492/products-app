//
//  ImageLoader.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

protocol ImageLoaderProtocol: Sendable {
    func loadImage(from url: URL) async -> UIImage?
}

actor ImageLoader: ImageLoaderProtocol {

    private let session: URLSession
    private let cache = NSCache<NSURL, UIImage>()
    private var activeTasks: [URL: Task<UIImage?, Never>] = [:]

    init(session: URLSession) {
        self.session = session
    }

    func loadImage(from url: URL) async -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }

        if let existing = activeTasks[url] {
            return await existing.value
        }

        let task = Task<UIImage?, Never> { [session] in
            do {
                let (data, _) = try await session.data(from: url)
                guard let image = UIImage(data: data) else { return nil }
                return image
            } catch {
                return nil
            }
        }
        activeTasks[url] = task

        let result = await task.value
        activeTasks.removeValue(forKey: url)

        if let result {
            cache.setObject(result, forKey: url as NSURL)
        }

        return result
    }

    func cancelAll() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
}
