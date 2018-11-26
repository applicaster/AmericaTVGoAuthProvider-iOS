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
    
    fileprivate var iapIdentifiers = [String]()
    fileprivate var productRequest: SKProductsRequest?
    fileprivate var products = [SKProduct]()
    
    override init() {
        super.init()
        
        iapIdentifiers = loadIAPIdentifiers()
    }
    
    fileprivate func loadIAPIdentifiers() -> [String] {
        var ids = [String]()
        
        if let iapListURL = Bundle(for: self.classForCoder).url(forResource: "iap", withExtension: "plist") {
            if let iapList = NSArray(contentsOf: iapListURL) {
                for id in iapList as! [String] {
                    ids.append(id)
                }
            }
        }
        
        return ids
    }
    
    fileprivate func validateIAPIdentifiers(_ identifiers: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        
        request.delegate = self
        
        self.productRequest = request
        self.productRequest?.start()
    }
    
    // MARK: -
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            if let index = iapIdentifiers.firstIndex(of: invalidIdentifier) {
                iapIdentifiers.remove(at: index)
            }
        }
    }
}
