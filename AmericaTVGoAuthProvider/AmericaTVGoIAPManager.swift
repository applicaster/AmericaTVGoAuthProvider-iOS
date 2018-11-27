//
//  AmericaTVGoIAPManager.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/20/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import StoreKit

class AmericaTVGoIAPManager: NSObject, SKProductsRequestDelegate {
    static let shared = AmericaTVGoIAPManager()
    
    lazy var currentUser: AmericaTVGoUser = {
        return AmericaTVGoUser()
    }()
    
    fileprivate var productRequest: SKProductsRequest?
    fileprivate var products = [AmericaTVGoProduct]()
    
    fileprivate var productRequestCompleted: (() -> Void)?
    
    override init() {
        super.init()
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
        let url = AmericaTVGoEndpointManager.shared.urlForEndpoint(ofType: .products)
        
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
                                let comps = value.split(separator: " ")
                                if comps.count == 2 {
                                    newProduct.timeDuration = String(comps[0])
                                    newProduct.timeUnit = String(comps[1])
                                }
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
        var cleanedProducts = Array(self.products)
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            if let index = self.products.firstIndex(where: {$0.identifier == invalidIdentifier}) {
                cleanedProducts.remove(at: index)
            }
        }
        
        self.products = cleanedProducts
        
        self.productRequestCompleted?()
    }
    
    // MARK: -
    
    func productWithIdentifier(_ id: String) -> AmericaTVGoProduct? {
        var foundProduct: AmericaTVGoProduct?
        
        for product in self.products {
            if product.identifier == id {
                foundProduct = product
                break
            }
        }
        
        return foundProduct
    }
    
}
