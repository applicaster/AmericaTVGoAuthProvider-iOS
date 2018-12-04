//
//  AmericaTVGoLoginAPIManager.swift
//  ZappLoginPluginAmericaTVGO
//
//  Created by Roi Kedarya on 09/07/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import UIKit
import AFNetworking
import ApplicasterSDK

let AmericaTVGoAPIManagerUserIDKey = "AmericaTVGoAPIManagerUserIDKey"
let AmericaTVGoAPIManagerUserEmailKey = "AmericaTVGoAPIManagerUserEmailKey"
let AmericaTVGoAPIManagerUserTokenKey = "AmericaTVGoAPIManagerUserTokenKey"

class AmericaTVGoAPIManager: NSObject {
    static let shared = AmericaTVGoAPIManager()
    
    var isProduction = false
    
//    public var apiUser:String?
//    public var apiKey:String?
    
    public func loginUser(email: String, password: String, completion:@escaping ((_ succes: Bool, _ token:String?, _ message: String?) -> Void)) {
        let parameters: [String: String] = ["correo":email,
                                        "password":password,
                                        "uuid":APIdentityClient.deviceID()]
        
        self.query(type: .login, parameters: parameters) { (_ success: Bool, _ jsonInfo: [String : Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            let user = AmericaTVGoIAPManager.shared.currentUser
                            user.update(json: objectDictionary)
                            self.updateUserDefaultsFromCurrentUser()
                            
                            if !user.token.isEmpty {
                                completion(true, user.token, message)
                            } else {
                                completion(true, nil, message)
                            }
                        } else {
                            //login failed
                            completion(false, nil, message)
                        }
                    }
                } else {
                    completion(false, nil, nil)
                }
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    public func forgotPassword(email: String, completion:@escaping ((_ success: Bool, _ message: String?) -> Void)) {
        let parameters: [String: String] = ["correo": email,
                                            "uuid": APIdentityClient.deviceID()]
        
        self.query(type: .passwordRecovery, parameters: parameters) { (_ success: Bool, _ jsonInfo: [String : Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            completion(true, message)
                        } else {
                            completion(false, message)
                        }
                    }
                } else {
                    completion(false, nil)
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    public func registerUser(email: String,
                             password: String,
                             isPremium: Bool,
                             completion:@escaping ((_ success: Bool, _ token:String?, _ message: String?) -> Void)) {
        let parameters: [String: String] = ["correo": email,
                                            "password": password,
                                            "uuid": APIdentityClient.deviceID(),
                                            "tipo": isPremium ? "1" : "0"]
        
        self.query(type: .registration, parameters: parameters) { (_ success: Bool, _ jsonInfo: [String : Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            let user = AmericaTVGoIAPManager.shared.currentUser
                            user.update(json: objectDictionary)
                            
                            self.updateUserDefaultsFromCurrentUser()
                            
                            completion(true, user.token, message)
                        } else {
                            completion(false, nil, message)
                        }
                    }
                } else {
                    completion(false, nil, nil)
                }
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    public func getUser(id: String, completion:@escaping ((_ success: Bool, _ token:String?, _ message: String?) -> Void)) {
        let parameters: [String: String] = ["idusuario": id,
                                            "uuid": APIdentityClient.deviceID()]
        
        self.query(type: .userDetails, parameters: parameters) { (_ success: Bool, _ jsonInfo: [String : Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            let user = AmericaTVGoIAPManager.shared.currentUser
                            user.update(json: objectDictionary)
                            
                            self.updateUserDefaultsFromCurrentUser()
                            
                            completion(true, user.token, message)
                        } else {
                            completion(false, nil, message)
                        }
                    }
                } else {
                    completion(false, nil, nil)
                }
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    // MARK: -
    
    fileprivate func query(type: AmericaTVGoEndpointType, parameters: [String: Any], completion: @escaping (_ success: Bool, _ jsonInfo: [String: Any]?) -> Void) {
        let sessionManager = AFHTTPSessionManager()
        sessionManager.requestSerializer = AFHTTPRequestSerializer()
        sessionManager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        sessionManager.responseSerializer = AFJSONResponseSerializer()
        
        let queryURL = AmericaTVGoEndpointManager.shared.urlForEndpoint(ofType: type, production: isProduction)
        
        sessionManager.post(queryURL.absoluteString,
                            parameters: parameters,
                            progress: nil,
                            success: { (task, object) in
                                if  let objectDictionary = object as? [String: Any] {
                                    completion(true, objectDictionary)
                                } else {
                                    completion(false, nil)
                                }
                                
        }) { (task, error) in
            completion(false, nil)
        }
    }
    
    fileprivate func getMessage(from jsonInfo:[String: Any]) -> String? {
        var message: String? = nil
        
        if let messages = jsonInfo["messages"] as? [Any] {
            if let messageID = messages.first as? String {
                message = AmericaTVGoEndpointManager.shared.messageForMessageID("\(messageID)")
            }
        }
        
        return message
    }
    
    fileprivate func updateUserDefaultsFromCurrentUser() {
        let user = AmericaTVGoIAPManager.shared.currentUser
        
        UserDefaults.standard.set(user.id, forKey: AmericaTVGoAPIManagerUserIDKey)
        UserDefaults.standard.set(user.email, forKey: AmericaTVGoAPIManagerUserEmailKey)
        UserDefaults.standard.set(user.token, forKey: AmericaTVGoAPIManagerUserTokenKey)
        
        UserDefaults.standard.synchronize()
    }
}


