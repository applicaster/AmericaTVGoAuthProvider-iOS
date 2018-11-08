//
//  AmericaTVGoEndpointManager.swift
//  AmericaTVGoAuthProvider-iOS
//
//  Created by Jesus De Meyer on 11/7/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import Foundation

@objc
enum AmericaTVGoEndpointType: Int {
    case registration
    case login
    case userDetails
    case userDetailsUpdate
    case passwordRecovery
    case subscription
}

@objc
class AmericaTVGoEnpointManager: NSObject {
    public static let shared = AmericaTVGoEnpointManager()
    public var isProductionEnvironment = false
    
    public func urlForEndpoint(ofType type: AmericaTVGoEndpointType) -> URL {
        var urlString: String
        
        switch type {
        case .registration:
            if isProductionEnvironment {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/registro"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/registro"
            }
        case .login:
            if isProductionEnvironment {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/login"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/login"
            }
        case .userDetails:
            if isProductionEnvironment {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/data"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/data"
            }
        case .userDetailsUpdate:
            if isProductionEnvironment {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/data"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/data"
            }
        case .passwordRecovery:
            if isProductionEnvironment {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/recupera/contrasena"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/recupera/contrasena"
            }
        case .subscription:
            if isProductionEnvironment {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/set/purchase"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/set/purchase"
            }
        }
        return URL(string: urlString)!
    }
}

