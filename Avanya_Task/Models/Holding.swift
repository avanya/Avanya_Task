//
//  Holding.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import Foundation

/// Represents a single stock holding in the user's portfolio.
struct Holding: Codable {
    let symbol: String
    let quantity: Double
    let lastTradedPrice: Double
    let averagePrice: Double
    let closePrice: Double
    
    // MARK: - Computed Properties
    
    /// Current market value = quantity × LTP
    var currentValue: Double {
        quantity * lastTradedPrice
    }
    
    /// Total investment made = quantity × average purchase price
    var totalInvestment: Double {
        quantity * averagePrice
    }
    
    /// Profit or loss for the current day = quantity × (close - LTP)
    var todaysPnL: Double {
        quantity * (closePrice - lastTradedPrice)
    }
    
    /// Total profit or loss = current value - total investment
    var totalPnL: Double {
        currentValue - totalInvestment
    }
    
    /// Profit or loss as a percentage of the investment
    var pnlPercentage: Double {
        (totalPnL / totalInvestment) * 100
    }
    
    // MARK: - Custom Coding Keys
    enum CodingKeys: String, CodingKey {
        case symbol
        case quantity
        case lastTradedPrice = "ltp"
        case averagePrice = "avgPrice"
        case closePrice = "close"
    }
}
