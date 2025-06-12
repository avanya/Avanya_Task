//
//  Portfolio.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import Foundation

/// Root model representing the portfolio response from the API.
struct Portfolio: Codable {
    let data: PortfolioData?
}

struct PortfolioData: Codable {
    /// List of individual holdings (stocks) in the portfolio.
    let userHolding: [Holding]
    
    // MARK: - Computed Summary Metrics
    
    /// Total current market value across all holdings.
    var currentValue: Double {
        userHolding.reduce(0) { $0 + $1.currentValue }
    }
    
    /// Total invested amount across all holdings.
    var totalInvestment: Double {
        userHolding.reduce(0) { $0 + $1.totalInvestment }
    }
    
    /// Total of today's profit or loss across all holdings.
    var todaysPnL: Double {
        userHolding.reduce(0) { $0 + $1.todaysPnL }
    }
    
    /// Net profit or loss = current value - total investment.
    var totalPnL: Double {
        currentValue - totalInvestment
    }
    
    /// Profit or loss as a percentage of the total investment.
    var pnlPercentage: Double {
        (totalPnL / totalInvestment) * 100
    }
}
