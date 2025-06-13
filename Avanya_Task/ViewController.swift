//
//  ViewController.swift
//  Avanya_Task
//
//  Created by Avanya Gupta on 12/06/25.
//

import UIKit

/// The main view controller displaying the portfolio summary and the list of holdings.
class ViewController: UIViewController {
    // MARK: - Properties

    /// ViewModel responsible for managing data and business logic
    private let viewModel: PortfolioViewModel
    
    /// Table view to show list of holdings
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.separatorStyle = .singleLine
        table.separatorInset = .zero
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    /// Summary view that displays total investment, P&L, etc.
    private lazy var summaryView = PortfolioSummaryView()
    private var summaryHeightConstraint: NSLayoutConstraint?

    /// Spinner for loading state
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    /// Pull-to-refresh control
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Initializers
    init(viewModel: PortfolioViewModel = PortfolioViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: "Main", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        self.viewModel = PortfolioViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Holdings"
        setupBindings()
        self.setupUI()
        viewModel.fetchPortfolio()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        setupTableView()
        setupSummaryView()
        showLoader()
    }
    
    /// Adds and configures the summary view at the bottom
    func setupSummaryView() {
        view.addSubview(summaryView)
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        summaryView.delegate = self
        summaryHeightConstraint = summaryView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        
        NSLayoutConstraint.activate([
            summaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryHeightConstraint!, // dynamic height constraint
        ])
        
    }
    
    /// Adds and configures the table view
    func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.register(HoldingCell.self, forCellReuseIdentifier: HoldingCell.reuseIdentifier)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(38 + view.safeAreaInsets.bottom))
        ])
    }
    
    func showLoader() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    /// Sets the view model's delegate to self
    private func setupBindings() {
        viewModel.delegate = self
    }
    // MARK: - Actions
    @objc private func refreshData() {
        refreshControl.beginRefreshing()
        viewModel.fetchPortfolio()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.portfolio?.data?.userHolding.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HoldingCell.reuseIdentifier, for: indexPath) as? HoldingCell,
              let holding = viewModel.portfolio?.data?.userHolding[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: holding)
        return cell
    }
}

// MARK: - PortfolioViewModelDelegate
extension ViewController: PortfolioViewModelDelegate {
    func didUpdatePortfolio() {
        didFinishLoading()
        tableView.reloadData()
        summaryView.update(with: viewModel)
    }
    
    func didFinishLoading() {
        hideLoader()
        refreshControl.endRefreshing()
    }
    
    func didReceiveError(_ error: String) {
        hideLoader()
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PortfolioSummaryViewDelegate
extension ViewController: PortfolioSummaryViewDelegate {
    func didTapExpandCollapse() {
        viewModel.toggleSummary()
        
        if !viewModel.isCollapsed {
            UIView.animate(withDuration: 0.2) {
                self.summaryHeightConstraint?.constant = self.viewModel.isCollapsed ? 38 : 150
                self.view.layoutIfNeeded()
            }
        } else {
            self.summaryHeightConstraint?.constant = self.viewModel.isCollapsed ? 38 : 150
            self.view.layoutIfNeeded()
        }
    }
}
