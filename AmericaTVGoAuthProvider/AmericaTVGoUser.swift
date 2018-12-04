//
//  AmericaTVGoUser.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/27/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import Foundation

enum AmericaTVGoUserGender: Int {
    case male
    case female
    case unknown
}

class AmericaTVGoUser {
    var id: String = ""
    var firstName: String = ""
    var lastNameFather: String = ""
    var lastNameMother: String = ""
    var email: String = ""
    var password: String = ""
    var gender: AmericaTVGoUserGender = .unknown
    var isPremium: Bool = false
    var product: AmericaTVGoProduct?
    var token: String = ""
    
    func update(json: [String: Any]) {
        if let value = json["token"] as? String {
            self.token = value
        }
        
        guard let details = json["data"] as? [String: Any] else {
            return
        }
        
        /*
         Not sure if these are needed:
         "dni": "3234..",
         "departamento": "0",
         "provincia": "0",
         "distrito": "0",
         "telefono": "0",
         "direccion": "0", "fecha_nacimiento": "1969-12-31"
        */
        
        if let value = details["idusuario"] as? String {
            self.id = value
        }
        if let value = details["nombres"] as? String {
            self.firstName = value
        }
        if let value = details["apellidos"] as? String {
            self.lastNameFather = value
        }
        if let value = details["apellidos_ma"] as? String {
            self.lastNameMother = value
        }
        if let value = details["correo"] as? String {
            self.email = value
        }
        if let value = details["genero"] as? String {
            switch value {
            case "M":
                self.gender = .male
            case "F":
                self.gender = .female
            default:
                self.gender = .unknown
            }
        }
    }
}
