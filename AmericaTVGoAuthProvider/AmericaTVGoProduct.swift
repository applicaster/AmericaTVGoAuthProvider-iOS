//
//  AmericaTVGoProduct.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/21/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import Foundation

struct AmericaTVGoProduct {
    var identifier: String
    var timeDuration: String
    var timeUnit: String
    var oldPrice: String
    var newPrice: String
    
    init(identifier: String, duration: String, unit: String, oldPrice: String, newPrice: String) {
        self.identifier = identifier
        self.timeDuration = duration
        self.timeUnit = unit
        self.oldPrice = oldPrice
        self.newPrice = newPrice
    }
}
