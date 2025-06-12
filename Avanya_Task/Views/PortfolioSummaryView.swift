//
//  PortfolioSummaryView.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import UIKit

/// Delegate protocol to notify when the summary view is expanded or collapsed.
protocol PortfolioSummaryViewDelegate: AnyObject {
    func didTapExpandCollapse()
}

/// A custom UIView that shows portfolio summary rows and supports collapse/expand animation.
class PortfolioSummaryView: UIView {
    // MARK: - Delegate
    weak var delegate: PortfolioSummaryViewDelegate?
    
    // MARK: - UI Components
    
    /// Summary row showing current value
    private let currentValueRow = SummaryRowView(title: "Current value*", value: "")
    
    /// Summary row showing total investment
    private let investmentRow = SummaryRowView(title: "Total investment*", value: "")
    
    /// Summary row showing today's P&L
    private let todayPNLRow = SummaryRowView(title: "Today’s Profit & Loss*", value: "", valueColor: .systemRed)
    
    /// Summary row showing total P&L and toggle icon
    private let pnlRow = SummaryRowView(title: "Profit & Loss*", imageName: "chevron.up", imageConfig: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold), value: "", valueColor: .systemGreen)
    
    /// Divider line between sections
    private let divider = UIView()
    
    /// Stack view to arrange all rows vertically
    private let contentStack = UIStackView()
    
    /// Indicates whether the summary is collapsed or expanded
    var isCollapsed: Bool = true {
        didSet { toggleCollapse(animated: true) }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        toggleCollapse(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        toggleCollapse(animated: false)
    }
    
    // MARK: - Layout
    
    /// Applies corner radius to top corners only and adds a light gray border
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius: CGFloat = 10
        
        let roundedPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        // Create rounded mask for top corners
        let maskLayer = CAShapeLayer()
        maskLayer.path = roundedPath.cgPath
        layer.mask = maskLayer
        
        // Remove existing border layer if present
        if let existingBorder = layer.sublayers?.first(where: { $0.name == "TopRoundedBorder" }) {
            existingBorder.removeFromSuperlayer()
        }
        
        // Add custom border along the same rounded path
        let borderLayer = CAShapeLayer()
        borderLayer.path = roundedPath.cgPath
        borderLayer.strokeColor = UIColor.lightGray.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 0.5
        borderLayer.frame = bounds
        borderLayer.name = "TopRoundedBorder"
        layer.addSublayer(borderLayer)
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        
        // Tap gesture to handle expand/collapse
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleToggle))
        addGestureRecognizer(tap)
        
        divider.backgroundColor = .lightGray
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        contentStack.axis = .vertical
        contentStack.distribution = .equalSpacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(currentValueRow)
        contentStack.addArrangedSubview(investmentRow)
        contentStack.addArrangedSubview(todayPNLRow)
        contentStack.addArrangedSubview(divider)
        contentStack.addArrangedSubview(pnlRow)
        
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Actions
    
    /// Handles expand/collapse tap gesture
    @objc private func handleToggle() {
        isCollapsed.toggle()
        delegate?.didTapExpandCollapse()
    }
    
    /// Expands or collapses rows with animation
    private func toggleCollapse(animated: Bool) {
        let rows = [currentValueRow, investmentRow, todayPNLRow, divider]
        let transform = isCollapsed ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: .pi)
        rows.forEach { $0.isHidden = self.isCollapsed }
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.pnlRow.image.transform = transform
                
            }
            
        } else {
            pnlRow.image.transform = transform
        }
        
    }
    
    // MARK: - Update Method
    
    /// Updates the summary values from the view model
    func update(with viewModel: PortfolioViewModel) {
        let data = viewModel.portfolio?.data
        
        currentValueRow.valueLabel.text = "\(data?.currentValue.formatted() ?? "0.00")"
        investmentRow.valueLabel.text = "\(data?.totalInvestment.formatted() ?? "0.00")"
        todayPNLRow.valueLabel.text = "\(data?.todaysPnL.formatted() ?? "0.00")"
        todayPNLRow.valueLabel.textColor = (data?.todaysPnL ?? 0) < 0 ? .systemRed : .systemGreen
        
        pnlRow.valueLabel.text = data?.totalPnL.formattedWithPercentage(investment: data?.totalInvestment ?? 0)
        pnlRow.valueLabel.textColor = (data?.totalPnL ?? 0) < 0 ? .systemRed : .systemGreen
    }
}
