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

class AmericaTVGoAPIManager: NSObject {
    static let shared = AmericaTVGoAPIManager()
    
    var isProduction = false
    
//    public var apiUser:String?
//    public var apiKey:String?
    
    public func loginUser(email: String, password: String, completion:@escaping ((_ succes: Bool, _ token:String?, _ message: String?) -> Void)) {
        let sessionManager = AFHTTPSessionManager()
        sessionManager.requestSerializer = AFHTTPRequestSerializer()
        sessionManager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        sessionManager.responseSerializer = AFJSONResponseSerializer()
        let loginURL = AmericaTVGoEndpointManager.shared.urlForEndpoint(ofType: .login, production: isProduction)
        let params: [String: String] = ["correo":email,
                                        "password":password,
                                        "uuid":APIdentityClient.deviceID()]
    
        sessionManager.post(loginURL.absoluteString,
                            parameters: params,
                            progress: nil,
                            success: { (task, object) in
                                if  let objectDictionary = object as? NSDictionary {
                                    var message: String? = nil
                                    
                                    if let messageID = (objectDictionary["messages"] as? [Any])?.first as? Int {
                                        message = AmericaTVGoEndpointManager.shared.messageForMessageID("\(messageID)")
                                    }
                                    
                                    if let status = objectDictionary.object(forKey: "status") as? Bool {
                                         //Login succesful
                                        if status == true {
                                            if let token = objectDictionary["token"] as? String {
                                                completion(true, token, message)
                                            } else {
                                                //Go to payment methods (with user id)
                                                if let userID = objectDictionary.object(forKey: "idusuario") as? String {
                                                    UserDefaults.standard.set(userID, forKey: AmericaTVGoAPIManagerUserIDKey)
                                                    UserDefaults.standard.synchronize()
                                                    
                                                    completion(true, nil, message)
                                                } else {
                                                    //no userId & no token - this is an edge case, it should not happen, unless something
                                                    //with the regestration went wrong
                                                    completion(false, nil, message)
                                                }
                                            }
                                        } else {
                                            //login failed
                                            completion(false, nil, message)
                                        }
                                    }
                                }
                                
        }) { (task, error) in
            completion(false, nil, nil)
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
                            //paying user has a token and a new user (didn't pay) get a null value
                            let token = objectDictionary["token"] as? String
                            
                            if let userID = objectDictionary["idusuario"] as? String {
                                UserDefaults.standard.set(userID, forKey: AmericaTVGoAPIManagerUserIDKey)
                            }
                            
                            UserDefaults.standard.synchronize()
                            
                            completion(true, token, message)
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
}
