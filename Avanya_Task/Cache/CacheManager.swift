//
//  CacheManager.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 13/06/25.
//

import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private init() {}

    private let cacheFileName = "portfolio_cache.json"

    private var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(cacheFileName)
    }

    /// Save the portfolio object as JSON to disk
    func save(_ portfolio: Portfolio) {
        do {
            let data = try JSONEncoder().encode(portfolio)
            try data.write(to: cacheURL)
        } catch {
            print("Failed to save portfolio cache:", error)
        }
    }

    /// Load the cached portfolio from disk if available
    func load() -> Portfolio? {
        let fileManager = FileManager.default
            let url = cacheURL

            // Check if file exists first
            guard fileManager.fileExists(atPath: url.path) else {
                return nil
            }
        
        do {
            let data = try Data(contentsOf: cacheURL)
            // return nil of file is empty
            guard !data.isEmpty else {
                        print("Cache file exists but is empty.")
                        return nil
                    }
            return try JSONDecoder().decode(Portfolio.self, from: data)
        } catch {
            print("Failed to load portfolio cache:", error)
            return nil
        }
    }
}
