//
//  CoinStore.swift
//  Pawmodoro
//
//  Created by Mélaine Berthelot on 17/12/2025.
//

import Foundation
import StoreKit
internal import Combine

final class CoinStore: ObservableObject {
    
    @Published private(set) var items = [Product]()
    
    init() {
        Task { [weak self] in
            await self?.retrieveProducts()
        }
    }
}

private extension CoinStore {
    
    @MainActor
    func retrieveProducts() async {
        do {
            let products = try await Product.products(for: productIdentifiers).sorted(by: { $0.price < $1.price})
            items = products
        } catch {
            print(error)
        }
    }
}
