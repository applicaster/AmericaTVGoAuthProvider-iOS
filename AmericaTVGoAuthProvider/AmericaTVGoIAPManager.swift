//
//  AmericaTVGoIAPManager.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/20/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import StoreKit
import CommonCrypto

class AmericaTVGoIAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = AmericaTVGoIAPManager()
    
    lazy var currentUser: AmericaTVGoUser = {
        return AmericaTVGoUser()
    }()
    
    var purchasesAllowed: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    fileprivate var productRequest: SKProductsRequest?
    fileprivate var products = [AmericaTVGoProduct]()
    fileprivate var iapProducts = [SKProduct]()
    
    fileprivate var productRequestCompleted: (() -> Void)?
    
    override init() {
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    /*fileprivate func loadIAPIdentifiers() -> [String] {
        var ids = [String]()
        
        if let iapListURL = Bundle(for: self.classForCoder).url(forResource: "iap", withExtension: "plist") {
            if let iapList = NSArray(contentsOf: iapListURL) {
                for id in iapList as! [String] {
                    ids.append(id)
                }
            }
        }
        
        return ids
    }*/
    
    // MARK: -
    
    func retrieveRemoteProducts(completion: @escaping (_ products: [AmericaTVGoProduct]) -> Void){
        let url = AmericaTVGoEndpointManager.shared.urlForEndpoint(ofType: .products, production: false)
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            self.products.removeAll()
            
            if let jsonData = data, let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                if let status = json!["status"] as? NSNumber, status.boolValue == true {
                    if let remoteProducts = json!["paquetes"] as? [[String: Any]] {
                        for remoteProduct in remoteProducts {
                            var newProduct = AmericaTVGoProduct()
                            
                            if let value = remoteProduct["id"] as? String {
                                newProduct.identifier = value
                            }
                            if let value = remoteProduct["regular_price"] as? NSNumber {
                                newProduct.oldPrice = value.stringValue
                            }
                            if let value = remoteProduct["precio"] as? NSNumber {
                                newProduct.newPrice = value.stringValue
                            }
                            if let value = remoteProduct["titulo"] as? String {
                                newProduct.timeUnit = value 
                            }
                            if let value = remoteProduct["is_promotion"] as? NSNumber {
                                newProduct.isPromotion = value.boolValue
                            }
                            
                            self.products.append(newProduct)
                        }
                    }
                }
            } else {
                print("An error occured: \(error?.localizedDescription ?? "")")
            }
            
            self.validateIAPIdentifiers {
                DispatchQueue.main.async {
                    completion(self.products)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: -
    
    fileprivate func validateIAPIdentifiers(completion: @escaping () -> Void) {
        if self.products.isEmpty {
            completion()
        } else {
            let ids = self.products.map { $0.identifier }
            
            let request = SKProductsRequest(productIdentifiers: Set(ids))
            
            request.delegate = self
            
            self.productRequestCompleted = completion
            self.productRequest = request
            self.productRequest?.start()
        }
    }
    
    // MARK: -
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let ids = products.map { $0.identifier }
        
        iapProducts.removeAll()
        
        var validProducts = Array(self.products)
        
        for iapProduct in response.products {
            if response.invalidProductIdentifiers.contains(iapProduct.productIdentifier) && ids.contains(iapProduct.productIdentifier) {
                if let index = self.products.firstIndex(where: { $0.identifier == iapProduct.productIdentifier }) {
                    validProducts.remove(at: index)
                }
            } else {
                iapProducts.append(iapProduct)
            }
        }
//
//        var cleanedProducts = Array(self.products)
//
//        for invalidIdentifier in response.invalidProductIdentifiers {
//            if let index = self.products.firstIndex(where: {$0.identifier == invalidIdentifier}) {
//                cleanedProducts.remove(at: index)
//            }
//        }
        
        self.products = validProducts
        
        self.productRequestCompleted?()
    }
    
    // MARK: -
    
    func iapProductWithIdentifier(_ id: String) -> SKProduct? {
        for iapProduct in self.iapProducts {
            if iapProduct.productIdentifier == id {
                return iapProduct
            }
        }
        
        return nil
    }
    
    // MARK: -
    
    func submitProduct(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func productPurchasedWithIdentifier(_ identifier: String) -> Bool {
        guard let receiptURL = Bundle(for: self.classForCoder).appStoreReceiptURL else {
            return false
        }
        
        guard let receiptData = try? Data(contentsOf: receiptURL) else {
            return false
        }
        
        guard let receiptJSON = try? JSONSerialization.jsonObject(with: receiptData, options: []) as? [String: Any] else {
            return false
        }
        
        if let status = receiptJSON!["status"] as? NSNumber {
            print("Status \(status)")
        }
        
        return false
    }
    
    // MARK: -
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred:
                print("deferred")
            case .failed:
                print("failed \(transaction.error?.localizedDescription ?? "")")
            case .purchased:
                print("purchased")
            case .purchasing:
                print("is purchasing")
            case .restored:
                print("restored")
            }
        }
    }
    
    // MARK: - Utils
    
    /*fileprivate func hashedValueForAccountName(_ userAccountName: String) -> String? {
        let HASH_SIZE = Int(32)
        
        var hashedChars = [CUnsignedChar]()
        let accountName = userAccountName.utf8CString
        let accountNameLen = accountName.count
    
        // Confirm that the length of the user name is small enough
        // to be recast when calling the hash function.
        if accountNameLen > UInt32.max {
            print("Account name too long to hash: \(userAccountName)")
            return nil
        }
        CC_SHA256(accountName as! UnsafeRawPointer, CC_LONG(accountNameLen), hashedChars)
    
        // Convert the array of bytes into a string showing its hex representation.
        var userAccountHash = String()
        for i in 0..<HASH_SIZE {
            // Add a dash every four bytes, for readability.
            if (i != 0 && i%4 == 0) {
                userAccountHash += "-"
            }
            userAccountHash += String(format: "%02x", arguments: [hashedChars[i]])
        }
    
        return userAccountHash
    }*/
    
}
