//
//  SubscriptionWrapper.swift
//  Authenticator
//
//  Created by PRO 14 on 17.11.23.
//

import Foundation
import ApphudSDK
import StoreKit

enum SubscriptionType: String, Codable {
    case week, month, year
}

class SubscriptionWrapper {
    static let shared = SubscriptionWrapper()
    var paywalls: [ ApphudPaywall ] = []
    var products: [ ApphudProduct ] = []
    
    var skProducts: [Product] = []
    
    private init() {}
    
    func isSubscribed() -> Bool {
        Apphud.hasActiveSubscription()
    }
    
    func purchase(_ product: ApphudProduct, completion: ((Bool) -> Void)?) {
        Apphud.purchase(product) { result in
            print("Purchase Result error")
            DispatchQueue.main.async {
                if let subscription = result.subscription, subscription.isActive() {
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        }
    }
    
    func checkPaywalls(completion: (([ApphudProduct]) -> Void)?) {
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            self?.paywalls = paywalls
            
            self?.products = paywalls.first?.products ?? []
            
            completion?(self?.products ?? [])
        }
    }
    
    func restore(completion: ((Bool) -> Void)?) {
        Apphud.restorePurchases{ _, _, _ in
            DispatchQueue.main.async {
                completion?(SubscriptionWrapper.shared.isSubscribed())
            }
        }
    }
    
    func apphudProduct(for type: SubscriptionType) -> ApphudProduct? {
        let bundle = "com.narekghukasyan.Authenticator"
        switch type {
        case .month:
            return products.first(where: { $0.productId.contains("\(bundle).month") })
        case .week:
            return products.first(where: { $0.productId.contains("\(bundle).week") })
        case .year:
            return products.first(where: { $0.productId.contains("\(bundle).year") })
        }
    }
    
    func product(for type: SubscriptionType) -> SKProduct? {
        apphudProduct(for: type)?.skProduct
    }
    
    func purchase(_ product: Product) async throws {
        Task {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(_):
                    print("Success")
                case .pending, .userCancelled:
                    print("Wait")
                default:
                    print("UnKnown")
                }
            } catch {
                
            }
        }
    }
}

extension SKProduct {
    var priceString: String {
        return numberFormatter.string(from: price) ?? ""
    }
    
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        if justPrice == Double(Int(justPrice)) {
            numberFormatter.maximumFractionDigits = 0
        }
        return numberFormatter
    }
    
    var justPrice: Double {
        Double(truncating: price)
    }
}

extension SKProductDiscount {
    var priceString: String {
        return numberFormatter.string(from: price) ?? ""
    }
    
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        if justPrice == Double(Int(justPrice)) {
            numberFormatter.maximumFractionDigits = 0
        }
        return numberFormatter
    }
    
    var justPrice: Double {
        Double(truncating: price)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
