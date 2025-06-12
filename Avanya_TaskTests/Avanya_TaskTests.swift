//
//  Avanya_TaskTests.swift
//  Avanya_TaskTests
//
//  Created by Avanya Gupta on 12/06/25.
//

import XCTest
@testable import Avanya_Task

final class Avanya_TaskTests: XCTestCase {
    var service: NetworkService!
    
    override func setUp() {
        
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        service = NetworkService(session: session)
        
    }
    
    override func tearDownWithError() throws {
        service = nil
    }
    
    func testPortfolioSummaryCalculations() {
        let holdings: [Holding] = [
            Holding(symbol: "MAHABANK", quantity: 10, lastTradedPrice: 150, averagePrice: 120, closePrice: 145),
            Holding(symbol: "ICICI", quantity: 5, lastTradedPrice: 100, averagePrice: 110, closePrice: 105),
        ]
        
        let portfolio = PortfolioData(userHolding: holdings)
        
        // Current Value = (10 * 150) + (5 * 100) = 1500 + 500 = 2000
        XCTAssertEqual(portfolio.currentValue, 2000, accuracy: 0.01)
        
        // Total Investment = (10 * 120) + (5 * 110) = 1200 + 550 = 1750
        XCTAssertEqual(portfolio.totalInvestment, 1750, accuracy: 0.01)
        
        // Today's PnL = (10 * (145 - 150)) + (5 * (105 - 100)) = - 50 + 25 = -25
        XCTAssertEqual(portfolio.todaysPnL, -25, accuracy: 0.01)
        
        // Total PnL = 2000 - 1750 = 250
        XCTAssertEqual(portfolio.totalPnL, 250, accuracy: 0.01)
        
        // PnL % = (250 / 1750) * 100 = ~14.29%
        XCTAssertEqual(portfolio.pnlPercentage, 14.29, accuracy: 0.01)
    }
    
    func testPortfolioWithNoHoldings() {
        let portfolio = PortfolioData(userHolding: [])
        
        XCTAssertEqual(portfolio.currentValue, 0)
        XCTAssertEqual(portfolio.totalInvestment, 0)
        XCTAssertEqual(portfolio.todaysPnL, 0)
        XCTAssertEqual(portfolio.totalPnL, 0)
        XCTAssertTrue(portfolio.pnlPercentage.isNaN)
    }
    
    func testPortfolioWithZeroQuantityHolding() {
        let holdings = [
            Holding(symbol: "SBI", quantity: 0, lastTradedPrice: 100, averagePrice: 90, closePrice: 95)
        ]
        let portfolio = PortfolioData(userHolding: holdings)
        
        XCTAssertEqual(portfolio.currentValue, 0)
        XCTAssertEqual(portfolio.totalInvestment, 0)
        XCTAssertEqual(portfolio.todaysPnL, 0)
        XCTAssertEqual(portfolio.totalPnL, 0)
        XCTAssertTrue(portfolio.pnlPercentage.isNaN)
    }
    
    func testPortfolioWithLoss() {
        let holdings = [
            Holding(symbol: "LOSS", quantity: 10, lastTradedPrice: 90, averagePrice: 100, closePrice: 80)
        ]
        let portfolio = PortfolioData(userHolding: holdings)
        
        XCTAssertEqual(portfolio.currentValue, 900)
        XCTAssertEqual(portfolio.totalInvestment, 1000)
        XCTAssertEqual(portfolio.todaysPnL, -100)
        XCTAssertEqual(portfolio.totalPnL, -100)
        XCTAssertEqual(portfolio.pnlPercentage, -10.0, accuracy: 0.01)
    }
    
    func testPortfolioMixedHoldings() {
        let holdings = [
            Holding(symbol: "A", quantity: 2, lastTradedPrice: 50, averagePrice: 40, closePrice: 48),
            Holding(symbol: "B", quantity: 3, lastTradedPrice: 30, averagePrice: 35, closePrice: 32),
            Holding(symbol: "C", quantity: 5, lastTradedPrice: 20, averagePrice: 20, closePrice: 22),
        ]
        let portfolio = PortfolioData(userHolding: holdings)
        
        XCTAssertEqual(portfolio.currentValue, 100 + 90 + 100) // = 290
        XCTAssertEqual(portfolio.totalInvestment, 80 + 105 + 100) // = 285
        XCTAssertEqual(portfolio.todaysPnL, -4 + 6 + 10) // = 12
        XCTAssertEqual(portfolio.totalPnL, 5)
        XCTAssertEqual(portfolio.pnlPercentage, (5.0 / 285.0) * 100, accuracy: 0.01)
    }
    
    func testPortfolioWithDecimalValues() {
        let holdings = [
            Holding(symbol: "DEC", quantity: 1.5, lastTradedPrice: 123.456, averagePrice: 100.123, closePrice: 122.111)
        ]
        let portfolio = PortfolioData(userHolding: holdings)
        
        let expectedCurrent = 1.5 * 123.456
        let expectedInvestment = 1.5 * 100.123
        let expectedTodaysPnL = 1.5 * (122.111 - 123.456)
        let expectedTotalPnL = expectedCurrent - expectedInvestment
        let expectedPnlPct = (expectedTotalPnL / expectedInvestment) * 100
        
        XCTAssertEqual(portfolio.currentValue, expectedCurrent, accuracy: 0.001)
        XCTAssertEqual(portfolio.totalInvestment, expectedInvestment, accuracy: 0.001)
        XCTAssertEqual(portfolio.todaysPnL, expectedTodaysPnL, accuracy: 0.001)
        XCTAssertEqual(portfolio.totalPnL, expectedTotalPnL, accuracy: 0.001)
        XCTAssertEqual(portfolio.pnlPercentage, expectedPnlPct, accuracy: 0.001)
    }
    
    
    func testFetchPortfolioSuccess() async throws {
        let json = """
            {
                "data": {
                    "userHolding": [
                        { "symbol": "AAPL", "quantity": 10, "ltp": 150, "avgPrice": 120, "close": 145 }
                    ]
                }
            }
            """.data(using: .utf8)
        
        MockURLProtocol.stubResponseData = json
        MockURLProtocol.stubStatusCode = 200
        
        
        let result = try await service.fetchPortfolio(url: "https://mock.com/portfolio")
        XCTAssertEqual(result.data?.userHolding.count, 1)
        XCTAssertEqual(result.data?.userHolding.first?.symbol, "AAPL")
    }
    
    func testFetchPortfolioDecodingError() async {
        let badJson = "INVALID_JSON".data(using: .utf8)!
        
        MockURLProtocol.stubResponseData = badJson
        MockURLProtocol.stubStatusCode = 200
        
        do {
            _ = try await service.fetchPortfolio(url: "https://mock.com/portfolio")
            XCTFail("Expected decodingError")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .decodingError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchPortfolioInvalidResponse() async {
        let json = "{}".data(using: .utf8)
        MockURLProtocol.stubResponseData = json
        MockURLProtocol.stubStatusCode = 500
        
        do {
            _ = try await service?.fetchPortfolio(url: "https://mock.com/portfolio")
            XCTFail("Expected invalidResponse error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .invalidResponse)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
