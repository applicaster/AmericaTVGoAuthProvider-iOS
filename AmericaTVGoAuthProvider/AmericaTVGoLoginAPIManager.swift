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

class AmericaTVGoLoginAPIManager: NSObject {
    static let sharedInstance = AmericaTVGoLoginAPIManager()
    
    static let baseURLString = "https://tvgo.americatv.com.pe/api/usuarios/app/"
    public static let userIDKey = "AmericaTVGoLoginUserID"
//    public var apiUser:String?
//    public var apiKey:String?
    
    public func loginUser(email: String, password: String, completion:@escaping ((_ succes: Bool, _ token:String?) -> Void)) {
        let sessionManager = AFHTTPSessionManager()
        sessionManager.requestSerializer = AFHTTPRequestSerializer()
        sessionManager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        sessionManager.responseSerializer = AFJSONResponseSerializer()
        let loginURL = AmericaTVGoLoginAPIManager.baseURLString +  "login/"
        let params: [String: String] = ["correo":email,
                                        "password":password,
                                        "uuid":APIdentityClient.deviceID()]
    
        sessionManager.post(loginURL,
                            parameters: params,
                            progress: nil,
                            success: { (task, object) in
                                if  let objectDictionary = object as? NSDictionary {
                                    if let status = objectDictionary.object(forKey: "status") as? Bool {
                                         //Login succesful
                                        if status == true {
                                            if let token = objectDictionary["token"] as? String {
                                                completion(true,token)
                                            } else {
                                                //Go to payment methods (with user id)
                                                if let userID = objectDictionary.object(forKey: "idusuario") as? String {
                                                    completion(true,nil)
                                                    UserDefaults.standard.set(userID, forKey: AmericaTVGoLoginAPIManager.userIDKey)
                                                    UserDefaults.standard.synchronize()
                                                } else {
                                                    //no userId & no token - this is an edge case, it should not happen, unless something
                                                    //with the regestration went wrong
                                                    completion(false,nil)
                                                }
                                            }
                                        } else {
                                            //login failed
                                            completion(false,nil)
                                        }
                                        
                                    }
                                }
                                
        }) { (task, error) in
            completion(false,nil)
        }
    }
    
    public func forgotPassword(email: String, completion:@escaping ((_ succes: Bool) -> Void)) {
    }
    
    public func registerUser(email: String,
                             password: String,
                             completion:@escaping ((_ succes: Bool, _ token:String?) -> Void)) {
    
        let sessionManager = AFHTTPSessionManager()
        sessionManager.requestSerializer = AFHTTPRequestSerializer()
        sessionManager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        sessionManager.responseSerializer = AFJSONResponseSerializer()
        let registerURL = AmericaTVGoLoginAPIManager.baseURLString +  "registro/"
        let parameters: [String: String] = ["correo": email,
                                            "password": password,
                                            "uuid": APIdentityClient.deviceID(),
                                            "tipo": "1"]
        
        sessionManager.post(registerURL,
                            parameters: parameters,
                            progress: nil,
                            success: { (task, object) in
                                if  let objectDictionary = object as? NSDictionary {
                                    if let status = objectDictionary.object(forKey: "status") as? Bool {
                                        if status == true {
                                            //paying user has a token and a new user (didn't pay) get a null value
                                            if let token = objectDictionary["token"] as? String {
                                                //registration was succesful - show login screen for user to login
                                                completion(true,token)
                                            } else {
                                                if let userID = objectDictionary.object(forKey: "idusuario") as? String {
                                                    
                                                }
                                            }
                                        } else {
                                            //registration failed
                                            completion(false,nil)
                                        }
                                    }
                                    //UserDefaults.standard.set(userID, forKey: AmericaTVGoLoginAPIManager.userIDKey)
                                    UserDefaults.standard.synchronize()
                                }
                                completion(false,nil)
        }) { (task, error) in
            completion(false,nil)
        }
    }
}
