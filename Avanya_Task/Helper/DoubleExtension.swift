//
//  DoubleExtension.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import Foundation

extension Double {
    /// Formats a Double as a currency string with 2 decimal places and commas.
    /// Adds a "₹" symbol and negative sign where needed.
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let formattedString = formatter.string(from: NSNumber(value: abs(self))) ?? ""
        return (self < 0 ? "-₹ " : "₹ ") + formattedString
    }
    
    /// Formats the amount and includes its percentage relative to the investment.
    func formattedWithPercentage(investment: Double) -> String {
        let percent = (self / investment) * 100
        return String(format: "\(self.formatted()) (%.2f%%)", abs(percent))
    }
}
