//
//  ProductListViewController.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import UIKit

final class ProductListViewController: UIViewController {

    private let viewModel: ProductListViewModel
    private let imageLoader: ImageLoaderProtocol

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = UIColor.systemGroupedBackground
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = Constants.ProductList.estimatedRowHeight
        tv.register(ProductCell.self, forCellReuseIdentifier: ProductCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private lazy var errorView: ErrorView = {
        let ev = ErrorView()
        ev.isHidden = true
        ev.translatesAutoresizingMaskIntoConstraints = false
        ev.onRetry = { [weak self] in self?.viewModel.retry() }
        return ev
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let es = EmptyStateView()
        es.isHidden = true
        es.translatesAutoresizingMaskIntoConstraints = false
        return es
    }()

    private lazy var paginationFooter: UIView = Self.makePaginationFooter()

    init(viewModel: ProductListViewModel, imageLoader: ImageLoaderProtocol) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupRefreshControl()
        viewModel.delegate = self
        viewModel.loadInitial()
    }

    private func setupNavigationBar() {
        title = Constants.Copy.listTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupViews() {
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        errorView.pinToEdges(of: view)
        emptyStateView.pinToEdges(of: view)
    }

    private func setupRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresh
    }

    private func render(state: ProductListViewState) {
        loadingIndicator.stopAnimating()
        errorView.isHidden = true
        emptyStateView.isHidden = true
        tableView.tableFooterView = nil
        tableView.refreshControl?.endRefreshing()

        switch state {
        case .idle:
            break
        case .loading:
            tableView.isHidden = true
            loadingIndicator.startAnimating()
        case .loadingMore:
            tableView.isHidden = false
            tableView.tableFooterView = paginationFooter
        case .loaded:
            tableView.isHidden = false
        case .empty:
            tableView.isHidden = true
            emptyStateView.isHidden = false
        case .error(let error):
            tableView.isHidden = true
            errorView.isHidden = false
            errorView.configure(for: error)
        }
    }

    @objc private func handleRefresh() {
        viewModel.loadInitial()
    }

    private static func makePaginationFooter() -> UIView {
        let footer = UIView()
        footer.translatesAutoresizingMaskIntoConstraints = false

        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        footer.addSubview(spinner)

        NSLayoutConstraint.activate([
            footer.heightAnchor.constraint(equalToConstant: Constants.ProductList.paginationFooterHeight),
            spinner.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: footer.centerYAnchor)
        ])

        footer.layoutIfNeeded()
        return footer
    }
}

// MARK: – ProductListViewModelDelegate

extension ProductListViewController: ProductListViewModelDelegate {

    func viewModelDidChangeState(_ viewModel: ProductListViewModel, state: ProductListViewState) {
        render(state: state)
    }

    func viewModelDidUpdateProducts(
        _ viewModel: ProductListViewModel,
        insertedRows: Range<Int>,
        isInitialLoad: Bool
    ) {
        if isInitialLoad {
            tableView.reloadData()
        } else {
            let indexPaths = insertedRows.map {
                IndexPath(row: $0, section: Constants.Pagination.tableSection)
            }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
}

// MARK: – UITableViewDataSource

extension ProductListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProductCell.reuseIdentifier,
            for: indexPath
        ) as? ProductCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.products[indexPath.row], imageLoader: imageLoader)
        return cell
    }
}

// MARK: – UITableViewDelegate

extension ProductListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectProduct(at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        viewModel.loadNextPageIfNeeded(at: indexPath.row)
    }
}
