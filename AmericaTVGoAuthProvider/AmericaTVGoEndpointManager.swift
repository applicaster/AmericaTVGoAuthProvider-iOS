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
    case products
}

@objc
class AmericaTVGoEndpointManager: NSObject {
    public static let shared = AmericaTVGoEndpointManager()
    
    public func urlForEndpoint(ofType type: AmericaTVGoEndpointType, production: Bool = true) -> URL {
        var urlString: String
        
        switch type {
        case .registration:
            if production {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/registro"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/registro"
            }
        case .login:
            if production {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/login"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/login"
            }
        case .userDetails:
            if production {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/data"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/data"
            }
        case .userDetailsUpdate:
            if production {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/data"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/data"
            }
        case .passwordRecovery:
            if production {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/recupera/contrasena"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/recupera/contrasena"
            }
        case .subscription:
            if production {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/set/purchase"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/set/purchase"
            }
        case .products:
            if production {
                urlString = "https://tvgo.americatv.com.pe/api/usuarios/app/list/paquetes"
            } else {
                urlString = "http://dev.tvgo.americadigital.pe/api/usuarios/app/list/paquetes"
            }
        }
        return URL(string: urlString)!
    }
    
    // MARK: -
    
    func messageForMessageID(_ messageID: String) -> String? {
        var messageList = [String: String]()
        
        messageList["100101"] = "Las credenciales de comunicación son incorrectas!"
        messageList["100102"] = "La transacción debe enviar # CELULAR o DNI."
        messageList["100103"] = "Enviar data."
        messageList["100104"] = "Ok!"
        messageList["100105"] = "Se registra solicitud con estado cancelado!"
        messageList["100106"] = "Data incompleta..."
        messageList["100107"] = "La data se guardó con éxito!"
        messageList["100108"] = "El monto enviado no corresponde a ningún paquete de recarga."
        messageList["100109"] = "Lo siento, ocurrió un error, el usuario no estaba registrado."
        messageList["100110"] = "Gracias por registrarse, ahora puede iniciar sesión."
        messageList["100111"] = "Lo siento, no tiene un paquete asignado a este pago."
        messageList["100112"] = "El usuario para suscribirse no está registrado."
        messageList["100113"] = "Lo siento, se produjo un error interno, intente nuevamente."
        messageList["100114"] = "Su código se ha guardado correctamente. Ahora puede disfrutar de nuestro contenido."
        messageList["100115"] = "¡Ya está registrado en TvGo, por favor inicie sesión!"
        messageList["100116"] = "¡El dominio de correo está en la lista negra!"
        messageList["100117"] = "Ingrese una dirección de correo electrónico válida."
        messageList["100118"] = "¡Es obligatorio!"
        messageList["100119"] = "¡El Apikey ingresado es incorrecto!"
        messageList["100120"] = "Ingrese el mínimo permitido para el campo."
        messageList["100121"] = "Ingrese el máximo permitido por el campo."
        messageList["100122"] = "Debe tener una suscripción activa para poder ver los videos."
        messageList["100123"] = "Nombre de usuario y / o contraseña incorrectos."
        messageList["100124"] = "Debe tener una suscripción activa."
        messageList["100125"] = "Enviar id de usuario."
        messageList["100126"] = "Este Campo sólo puede contener caracteres alfabéticos y comillas simples."
        messageList["100127"] = "El valor ingresado no es valido."
        messageList["100128"] = "El Teléfono ingresado tiene formato inválido."
        messageList["100129"] = "La Fecha ingresada no tiene el formato correcto."
        messageList["100130"] = "Debe ingresar un DNI valido."
        messageList["100131"] = "Su nueva contraseña se le envió a su correo."
        
        if let message = messageList[messageID] {
            return message
        }
        
        return nil
    }
}

