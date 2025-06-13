//
//  NetworkService.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import Foundation

/// Enum representing possible errors that can occur during a network request
/// Enum representing possible errors that can occur during a network request
enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL, .invalidResponse, .decodingError:
            return "Something went Wrong"
        case .networkError(let error):
            return error.localizedDescription
        }
    }

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError):
            return true
        case (.networkError, .networkError):
            return true
        default:
            return false
        }
    }
}

/// Protocol defining the interface for network operations related to the portfolio
protocol NetworkServiceProtocol {
    /// Fetches the Portfolio model from the given URL
    func fetchPortfolio(url: String) async throws -> Portfolio
}

class NetworkService: NetworkServiceProtocol {
    /// The URLSession instance to use for network calls. Defaults to `.shared`, but injectable for testing.
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Fetches portfolio data from a remote server
    /// - Parameter url: A string URL where the JSON data is located
    /// - Returns: A decoded `Portfolio` model
    /// - Throws: `NetworkError` if something goes wrong during the network call or decoding
    func fetchPortfolio(url: String) async throws -> Portfolio {
        // Step 1: Validate URL
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        // Step 2: Perform network request using async/await
        let (data, response) = try await session.data(from: url)
        
        // Step 3: Validate HTTP status code
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        // Step 4: Decode JSON response into Portfolio model
        do {
            let portfolio = try JSONDecoder().decode(Portfolio.self, from: data)
            return portfolio
        } catch {
            throw NetworkError.decodingError
        }
    }
}
