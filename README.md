# Products App

Products App is a sample iOS application built with UIKit that showcases a modern, scalable architecture for fetching, displaying, and navigating paginated data from a remote API. It displays a list of electronic products, allows users to view details, and gracefully handles various states like loading, errors, and empty results.

## App Glimpses

| Products List | Product Details |
| -- | -- |
| <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-10 at 22 11 50" src="https://github.com/user-attachments/assets/191eea11-09e7-4aa5-acdb-4f616433daaa" /> | <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-10 at 22 12 40" src="https://github.com/user-attachments/assets/6ec726d8-9cb1-49f3-ae3c-4ebe8cdbd052" /> |

| No Connection | Empty State |
| -- | -- |
|<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-10 at 22 19 11" src="https://github.com/user-attachments/assets/45285ecc-d529-4020-8f64-be6ccf5331e3" /> | <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-06-10 at 22 22 50" src="https://github.com/user-attachments/assets/3bf0d717-a467-42c4-9d17-6c478095347e" /> |

---



## Features

- Displays a paginated list of products from a network API.
- Infinite scrolling to load subsequent pages as the user scrolls.
- Pull-to-refresh functionality to reload the product list.
- Detailed view for each product, showing more information and a larger image.
- Asynchronous image loading with caching to ensure a smooth user experience and reduce network usage.
- Robust error handling for network connectivity issues and data parsing failures.
- Dedicated UI for loading, empty, and error states.
- Comprehensive unit test coverage for key components like ViewModels, Repositories, and Routers.

## Architecture

The project is built using the MVVM-R (Model-View-ViewModel-Router) design pattern, which promotes a clean separation of concerns, enhances testability, and simplifies navigation logic.

1. Model: Represents the data entities of the app, such as Product and PaginatedResult.
2. View: The UI layer, composed of UIViewControllers and UIViews, responsible for presenting data and capturing user input. Views are dumb and delegate all logic to the ViewModel.
3. ViewModel: Acts as a bridge between the Model and the View. It prepares data for presentation, handles user actions, and manages the view's state.
4. Router: Manages the navigation flow of the application, decoupling ViewControllers from each other.
5. Repository: Abstracts the data source, providing a clean API for the ViewModel to fetch data from the network.
6. NetworkClient: A generic, async/await-based client for handling all network requests.
7. AppContainer: Wires everything together and builds the concrete dependencies used by the screens.

---

## Setup

### Requirements

- Xcode 26+
- iOS 26+
- Swift 6

### Build & Run

```bash
git clone https://github.com/Omkar492/products-app.git
```

## Author

- [Omkar Chougule](https://www.linkedin.com/in/omkar492) 🙋‍♂️


