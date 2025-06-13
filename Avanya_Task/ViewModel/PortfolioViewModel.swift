//
//  PortfolioViewModel.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import Foundation

/// Delegate protocol to notify the view of portfolio updates, errors, and loading state changes.
protocol PortfolioViewModelDelegate: AnyObject {
    func didUpdatePortfolio()
    func didFinishLoading()
    func didReceiveError(_ error: String)
}

class PortfolioViewModel {
    /// The fetched portfolio model from the API
    private(set) var portfolio: Portfolio?
    
    /// Indicates whether a network call is currently in progress
    private(set) var isLoading = false
    
    /// Stores any error message encountered during data fetch
    private(set) var error: String?
    
    /// Controls the collapsed/expanded state of the summary view
    private(set) var isCollapsed = true
    
    weak var delegate: PortfolioViewModelDelegate?
    
    private let networkService: NetworkServiceProtocol
    
    let url = "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/"
    
    /// Initializer that allows dependency injection of a custom network service
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchPortfolio() {
        isLoading = true
        error = nil

        Task { [weak self] in
            guard let self else { return }
            // Get from cache first
            if let cached = CacheManager.shared.load() {
                self.portfolio = cached
                await MainActor.run {
                    self.delegate?.didUpdatePortfolio()
                }
            }

            // Getting from network
            do {
                let result = try await networkService.fetchPortfolio(url: url)
                self.portfolio = result

                //Saving new data to Cache
                CacheManager.shared.save(result)

                await MainActor.run {
                    self.delegate?.didUpdatePortfolio()
                }
            } catch {
                self.error = error.localizedDescription
                await MainActor.run {
                    self.delegate?.didReceiveError(error.localizedDescription)
                }
            }

            self.isLoading = false
            await MainActor.run {
                self.delegate?.didFinishLoading()
            }
        }
    }

    /// Toggles the summary view's collapsed/expanded state
    func toggleSummary() {
        isCollapsed.toggle()
    }
}
