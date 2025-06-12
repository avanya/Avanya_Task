//
//  SummaryRowView.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import UIKit

class SummaryRowView: UIView {
    // MARK: - UI Elements
    let titleLabel = UILabel()
    let image = UIImageView()
    let valueLabel = UILabel()
    
    // MARK: - Initializer
    /// Initializes the row view with title, optional icon, and value.
    /// - Parameters:
    ///  - title: Title text to display (left-aligned).
    ///  - imageName: Optional SF Symbol name (e.g., "arrow.down").
    ///  - imageConfig: Optional `UIImage.SymbolConfiguration` for sizing.
    ///  - value: Value text to display (right-aligned).
    ///  - valueColor: Color of the value text (default is black).
    
    init(title: String, imageName: String? = nil, imageConfig: UIImage.SymbolConfiguration? = nil, value: String, valueColor: UIColor = .black) {
        super.init(frame: .zero)
        
        // Configure title label
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // Configure image view if an icon is provided
        if let imageName {
            image.image = UIImage(systemName: imageName, withConfiguration: imageConfig)
            image.tintColor = .gray
        }
        
        // Configure value label
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 12)
        valueLabel.textAlignment = .right
        valueLabel.textColor = valueColor
        
        // Setup horizontal stack view
        let rowStack = UIStackView(arrangedSubviews: [titleLabel, image, valueLabel])
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(rowStack)
        
        // Pin stack view to all edges of the parent view
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            rowStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
