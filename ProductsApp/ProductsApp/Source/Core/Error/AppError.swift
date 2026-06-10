//
//  AppError.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import Foundation

enum AppError: Error, LocalizedError, Equatable {
    case noInternetConnection
    case serverError(statusCode: Int)
    case decodingFailed
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return Constants.Copy.noInternetMessage
        case .serverError(let code):
            return String(format: Constants.Copy.serverErrorMessage, code)
        case .decodingFailed:
            return Constants.Copy.decodingFailedMessage
        case .unknown(let msg):
            return msg.isEmpty ? Constants.Copy.unknownErrorMessage : msg
        }
    }

    var isNetworkError: Bool {
        if case .noInternetConnection = self { return true }
        return false
    }
}
