//
//  NetworkClient.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw AppError.unknown(Constants.API.invalidURLError)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        endpoint.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet ||
               urlError.code == .networkConnectionLost {
                throw AppError.noInternetConnection
            }
            throw AppError.unknown(urlError.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.unknown(Constants.API.nonHTTPResponseError)
        }

        guard Constants.API.successStatusCodeRange.contains(httpResponse.statusCode) else {
            throw AppError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AppError.decodingFailed
        }
    }
}
