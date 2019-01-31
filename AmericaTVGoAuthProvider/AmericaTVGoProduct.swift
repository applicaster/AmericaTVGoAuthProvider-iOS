//
//  AmericaTVGoProduct.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/21/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import Foundation

enum AmericaTVGoProductIdentifier: String {
    case yearly = "suscripcion_anual_1"
    case semester = "suscripcion_semestral_1"
    case monthly = "suscripcion_mensual_1"
}

struct AmericaTVGoProduct {
    var identifier: String
    var timeDuration: String
    var timeUnit: String
    var oldPrice: String
    var newPrice: String
    var isPromotion: Bool
    var promotionText: String
    
    init(identifier: String, duration: String, unit: String, oldPrice: String, newPrice: String, promotion: Bool, promotionText: String) {
        self.identifier = identifier
        self.timeDuration = duration
        self.timeUnit = unit
        self.oldPrice = oldPrice
        self.newPrice = newPrice
        self.isPromotion = promotion
        self.promotionText = promotionText
    }
    
    init() {
        self.init(identifier: "", duration: "", unit: "", oldPrice: "", newPrice: "", promotion: false, promotionText: "")
    }
}
