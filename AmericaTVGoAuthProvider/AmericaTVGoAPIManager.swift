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
import ZappPlugins

let AmericaTVGoAPIManagerUserIDKey = "AmericaTVGoAPIManagerUserIDKey"
let AmericaTVGoAPIManagerUserEmailKey = "AmericaTVGoAPIManagerUserEmailKey"
let AmericaTVGoAPIManagerUserTokenKey = "AmericaTVGoAPIManagerUserTokenKey"
let AmericaTVGoAPIManagerAuthProviderIDKey = "AmericaTVGoAPIManagerAuthProviderIDKey"

let AmericaTVGoAPIManagaerInvalidToken = "<invalid_token>"

class AmericaTVGoAPIManager: NSObject {
    static let shared = AmericaTVGoAPIManager()
    
    var isProduction = true
    
    public func loginUser(email: String, password: String, completion:@escaping ((_ succes: Bool, _ token:String?, _ message: String?) -> Void)) {
        let parameters: [String: String] = ["correo":email,
                                        "password":password,
                                        "uuid":ZAAppConnector.sharedInstance().identityDelegate.getDeviceId() ?? ""]
        
        self.query(type: .login, parameters: parameters) { (_ success: Bool, _ jsonInfo: [String : Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            let user = AmericaTVGoIAPManager.shared.currentUser
                            user.update(json: objectDictionary)
                            user.email = email
                            user.password = password
                            
                            AmericaTVGoAPIManager.updateUserDefaultsFromCurrentUser()
                            
                            self.updateToken(user.token)
                            
                            APKeychain.setString(password, forKey: user.email)
                            
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
                                            "uuid": ZAAppConnector.sharedInstance().identityDelegate.getDeviceId() ?? ""]
        
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
                                            "uuid": ZAAppConnector.sharedInstance().identityDelegate.getDeviceId() ?? "",
                                            "tipo": isPremium ? "1" : "0"]
        
        self.query(type: .registration, parameters: parameters) { (_ success: Bool, _ jsonInfo: [String : Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            let user = AmericaTVGoIAPManager.shared.currentUser
                            user.update(json: objectDictionary)
                            user.email = email
                            user.password = password
                            
                            AmericaTVGoAPIManager.updateUserDefaultsFromCurrentUser()
                            
                            self.updateToken(user.token)
                            
                            APKeychain.setString(password, forKey: user.email)
                            
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
                                            "uuid": ZAAppConnector.sharedInstance().identityDelegate.getDeviceId() ?? ""]
        
        self.query(type: .userDetails, parameters: parameters) { (_ success: Bool, _ jsonInfo: [String : Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            let user = AmericaTVGoIAPManager.shared.currentUser
                            user.update(json: objectDictionary)
                            AmericaTVGoAPIManager.updateUserDefaultsFromCurrentUser()
                            
                            self.updateToken(user.token)
                            
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
    
    public func registerPurchaseForUser(userID: String, packageName: String, subscriptionID: String, token: String, completion:@escaping ((_ success: Bool, _ token:String?, _ message: String?) -> Void)) {
        let paramaters = ["packageName": packageName,
                          "subscriptionId": subscriptionID,
                          "token": token,
                          "idusuario": userID,
                          "os": "ios"]
        
        self.query(type: .subscription, parameters: paramaters) { (_ success: Bool, _ jsonInfo: [String: Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            let user = AmericaTVGoIAPManager.shared.currentUser
                            user.update(json: objectDictionary)
                            AmericaTVGoAPIManager.updateUserDefaultsFromCurrentUser()
                            
                            self.updateToken(user.token)
                            
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
    
    func getPackages(completion: @escaping (_ success: Bool, _ jsonInfo: [String: Any]?, _ message: String?) -> Void) {
        let paramaters = ["partner": "applicaster",
                          "tipo": "ios"]
        
        self.query(type: .products, parameters: paramaters) { (_ success: Bool, _ jsonInfo: [String: Any]?) in
            if success {
                if let objectDictionary = jsonInfo {
                    let message = self.getMessage(from: objectDictionary)
                    
                    if let status = objectDictionary["status"] as? Bool {
                        if status == true {
                            completion(true, objectDictionary, message)
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
        
        let success = { (_ task: URLSessionTask, _ object: Any?) in
            if  let objectDictionary = object as? [String: Any] {
                completion(true, objectDictionary)
            } else {
                completion(false, nil)
            }
        }
        
        let fail = { (_ task: URLSessionTask?, _ error: Error?) in
            completion(false, nil)
        }
        
        if [.userDetails, .products].contains(type) {
            sessionManager.get(queryURL.absoluteString, parameters: parameters, progress: nil, success: { (task, object) in
                success(task, object)
            }) { (task, error) in
                fail(task, error)
            }
        } else {
            sessionManager.post(queryURL.absoluteString,
                                parameters: parameters,
                                progress: nil,
                                success: { (task, object) in
                                    success(task, object)
                                    
            }) { (task, error) in
                fail(task, error)
            }
        }
    }
    
    fileprivate func getMessage(from jsonInfo:[String: Any]) -> String? {
        var message: String? = nil
        
        if let messages = jsonInfo["messages"] as? [Any] {
            if let messageID = messages.first as? Int {
                if !AmericaTVGoEndpointManager.shared.isMessageOK(messageID) {
                    message = AmericaTVGoEndpointManager.shared.messageForMessageID("\(messageID)")
                }
            } else if let messageID = messages.first as? String {
                message = AmericaTVGoEndpointManager.shared.messageForMessageID("\(messageID)")
            }
        }
        
        return message
    }
    
    class func updateUserDefaultsFromCurrentUser() {
        let user = AmericaTVGoIAPManager.shared.currentUser
        
        UserDefaults.standard.set(user.id, forKey: AmericaTVGoAPIManagerUserIDKey)
        UserDefaults.standard.set(user.email, forKey: AmericaTVGoAPIManagerUserEmailKey)
        UserDefaults.standard.set(user.token, forKey: AmericaTVGoAPIManagerUserTokenKey)
        
        UserDefaults.standard.synchronize()
    }
    
    class func clearUserDefaultsFromCurrentUser() {
        UserDefaults.standard.removeObject(forKey: AmericaTVGoAPIManagerUserIDKey)
        UserDefaults.standard.removeObject(forKey: AmericaTVGoAPIManagerUserEmailKey)
        UserDefaults.standard.removeObject(forKey: AmericaTVGoAPIManagerUserTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    func updateToken(_ token: String) {
        if let authManager = APAuthorizationManager.sharedInstance(), let authProviderID = UserDefaults.standard.object(forKey: AmericaTVGoAPIManagerAuthProviderIDKey) as? String {
            if token.isEmpty {
                UserDefaults.standard.removeObject(forKey: AmericaTVGoAPIManagerUserTokenKey)
                
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let docDir = paths[0] as NSString
                let fullPath = docDir.appendingPathComponent("authorization_tokens.dat")
                
                let fm = FileManager.default
                
                if fm.fileExists(atPath: fullPath) {
                    if let _ = try? fm.removeItem(atPath: fullPath) {
                        // path deleted
                    }
                }
            } else {
                UserDefaults.standard.set(token, forKey: AmericaTVGoAPIManagerUserTokenKey)
                authManager.setAuthorizationToken(token, withAuthorizationProviderID: authProviderID)
            }
        }
    }
}


