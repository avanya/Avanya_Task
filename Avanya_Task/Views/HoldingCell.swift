//
//  HoldingCell.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import UIKit

/// A custom UITableViewCell that displays individual holding information such as symbol, LTP, quantity, and P&L.
class HoldingCell: UITableViewCell {
    
    /// Cell reuse identifier used for dequeuing
    static let reuseIdentifier = "HoldingCell"
    
    // MARK: - UI Elements
    
    /// Label displaying the stock symbol
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    /// Label displaying the last traded price
    private let ltpLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    /// Label showing the quantity held
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    /// Label showing the profit or loss
    private let pnlLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .right
        return label
    }()
    
    private let topRow = UIStackView()
    private let bottomRow = UIStackView()
    private let verticalStack = UIStackView()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        
        topRow.axis = .horizontal
        topRow.distribution = .equalSpacing
        topRow.alignment = .top
        topRow.addArrangedSubview(symbolLabel)
        topRow.addArrangedSubview(ltpLabel)
        
        bottomRow.axis = .horizontal
        bottomRow.distribution = .equalSpacing
        bottomRow.alignment = .top
        bottomRow.addArrangedSubview(quantityLabel)
        bottomRow.addArrangedSubview(pnlLabel)
        
        verticalStack.axis = .vertical
        verticalStack.spacing = 16
        verticalStack.addArrangedSubview(topRow)
        verticalStack.addArrangedSubview(bottomRow)
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verticalStack)
        
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with holding: Holding) {
        symbolLabel.text = holding.symbol
        ltpLabel.attributedText = styledLabel(title: "LTP: ", value: holding.lastTradedPrice.formatted(), color: .label)
        quantityLabel.attributedText = styledLabel(title: "NET QTY: ", value: "\(holding.quantity)")
        
        pnlLabel.attributedText = styledLabel(title: "P&L: ", value: holding.totalPnL.formatted(), color: holding.totalPnL >= 0 ? .systemGreen : .systemRed)
    }
    
    /// Returns a styled `NSAttributedString` with differently styled title and value
    private func styledLabel(title: String, value: String, color: UIColor? = nil) -> NSAttributedString {
        let titleFont = UIFont.systemFont(ofSize: 10)
        let valueFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        let attributed = NSMutableAttributedString(
            string: title,
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        
        attributed.append(NSAttributedString(
            string: value,
            attributes: [
                .font: valueFont,
                .foregroundColor: color ?? UIColor.label
            ]
        ))
        
        return attributed
    }
    
}
