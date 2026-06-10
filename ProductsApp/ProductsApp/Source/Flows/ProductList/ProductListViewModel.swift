//
//  ProductListViewModel.swift
//  ProductsApp
//
//  Created by Omkar Chougule on 09/06/26.
//

import Foundation

protocol ProductListViewModelDelegate: AnyObject {
    func viewModelDidChangeState(_ viewModel: ProductListViewModel, state: ProductListViewState)
    func viewModelDidUpdateProducts(
        _ viewModel: ProductListViewModel,
        insertedRows: Range<Int>,
        isInitialLoad: Bool
    )
}

final class ProductListViewModel {

    private(set) var products: [Product] = []
    private(set) var state: ProductListViewState = .idle
    private(set) var hasMorePages: Bool = true

    weak var delegate: ProductListViewModelDelegate?

    private let router: AppRouterProtocol
    private let repository: ProductRepositoryProtocol

    private var currentPage = Constants.Pagination.initialPage
    private var isFetching = false
    private var fetchTask: Task<Void, Never>?

    init(repository: ProductRepositoryProtocol, router: AppRouterProtocol) {
        self.repository = repository
        self.router = router
    }

    func loadInitial() {
        guard !isFetching else { return }

        fetchTask?.cancel()
        products = []
        currentPage = Constants.Pagination.initialPage
        hasMorePages = true
        updateState(.loading)

        fetchTask = Task { [weak self] in
            await self?.fetchPage(page: Constants.Pagination.initialPage)
        }
    }

    func loadNextPageIfNeeded(at row: Int) {
        guard hasMorePages, !isFetching, row == products.count - 1 else { return }
        updateState(.loadingMore)

        fetchTask = Task { [weak self] in
            guard let self else { return }
            await self.fetchPage(page: self.currentPage)
        }
    }

    func retry() {
        loadInitial()
    }

    func didSelectProduct(at row: Int) {
        guard products.indices.contains(row) else { return }
        router.navigate(to: .productDetail(products[row]))
    }

    @MainActor
    private func fetchPage(page: Int) async {
        guard !Task.isCancelled else { return }

        isFetching = true
        defer { isFetching = false }

        do {
            let result = try await repository.fetchProducts(
                page: page,
                limit: Constants.Pagination.pageSize,
                category: Constants.Pagination.category
            )

            guard !Task.isCancelled else { return }

            if result.data.isEmpty {
                if products.isEmpty {
                    updateState(.empty)
                } else {
                    hasMorePages = false
                    updateState(.loaded)
                }
                return
            }

            let startIndex = products.count
            products.append(contentsOf: result.data)

            if currentPage != result.pagination.nextPage {
                currentPage = result.pagination.nextPage
                hasMorePages = true
            } else {
                hasMorePages = false
            }

            updateState(.loaded)
            delegate?.viewModelDidUpdateProducts(
                self,
                insertedRows: startIndex..<products.count,
                isInitialLoad: startIndex == 0
            )
        } catch let appError as AppError {
            guard !Task.isCancelled else { return }
            updateState(.error(appError))
        } catch {
            guard !Task.isCancelled else { return }
            updateState(.error(.unknown(error.localizedDescription)))
        }
    }

    @MainActor
    private func updateState(_ newState: ProductListViewState) {
        state = newState
        delegate?.viewModelDidChangeState(self, state: newState)
    }
}
