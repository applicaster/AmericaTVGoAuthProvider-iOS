//
//  AmericaTVGoAuthProvider.swift
//  ZappLoginPluginAmericaTVGO
//
//  Created by Roi Kedarya on 16/07/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import ApplicasterSDK
import ZappPlugins
import ZappLoginPluginsSDK

public typealias AmericaTVGoAuthProviderCompletion = ((ZPLoginOperationStatus) -> Void)

class AmericaTVGoAuthProvider: NSObject, APAuthorizationClient, ZPAppLoadingHookProtocol, ZPBaseLoginProviderFlowHandler {
    var delegate: APAuthorizationClientDelegate!
    
    let uniqueID = "americaTV"
    
    var configurationJSON: NSDictionary?
    
    private var completion: AmericaTVGoAuthProviderCompletion?
    private var performingLogin = false
    
    required convenience init(configurationJSON: NSDictionary?) {
        self.init()
        self.configurationJSON = configurationJSON
    }
    
    required override init() {
        
    }
    
    required init!(authorizationProvider authProvider: APAuthorizationProvider!, andParams params: [AnyHashable : Any]!) {
        super.init()
    }
    
    // MARK: -
    
    func login(_ additionalParameters: [String : Any]?, completion: @escaping ((ZPLoginOperationStatus) -> Void)) {
        self.completion = completion
        self.performingLogin = true
        //self.startAuthorizationProcess()
        
    }
    
    func logout(_ completion: @escaping ((ZPLoginOperationStatus) -> Void)) {
        UserDefaults.standard.removeObject(forKey: AmericaTVGoIAPManager.shared.currentUser.email)
        UserDefaults.standard.removeObject(forKey: AmericaTVGoIAPManager.shared.currentUser.token)
        UserDefaults.standard.synchronize()
        completion(.cancelled)
    }
    
    func isAuthenticated() -> Bool {
        if let token = UserDefaults.standard.object(forKey: AmericaTVGoIAPManager.shared.currentUser.token) as? String, !token.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    // MARK: -
    
    func startAuthorizationProcess() {
        let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
        let americaTVGoLoginViewController = AmericaTVGoLoginViewController.init(nibName: "AmericaTVGoLoginViewController", bundle: Bundle(for: type(of: self)), andDelegate: delegate)
        topMostViewController?.present(americaTVGoLoginViewController, animated: true, completion: nil)
    }
    
    //MARK: ZPAppLoadingHookProtocol
    
    func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?) {
        let user = AmericaTVGoIAPManager.shared.currentUser
        
        if user.id.isEmpty {
            completion?()
        } else {
            //let oldToken = user.token.isEmpty
            
            AmericaTVGoAPIManager.shared.getUser(id: user.id) { (_ success: Bool, _ token: String?, _ message: String?) in
                if let userToken = token {
                    UserDefaults.standard.set(userToken, forKey: AmericaTVGoAPIManagerUserTokenKey)
                    self.login(nil) { (status) in
                        completion?()
                    }
                } else {
                    UserDefaults.standard.set(nil, forKey: AmericaTVGoAPIManagerUserTokenKey)
                    completion?()
                }
            }
        }
        let userHasToken = false
        if !userHasToken {
            self.login(nil, completion: { (status) in
                completion?()
            })
        }
        else {
            completion?();
        }
    }
    
    @objc public func handleUrlScheme(_ params:NSDictionary) {
        let expectedUrlSchemeNameParam = self.urlSchemeName()
        let nameParam = params["name"] as? String
        
        if expectedUrlSchemeNameParam.isEmpty || nameParam == expectedUrlSchemeNameParam {
            self.login(nil) { (status) in
                // Nothing to do for now
            }
        }
    }
    
    //MARK: ZPBaseLoginProviderFlowHandler
    func urlSchemeName() -> String {
        return "americatvgo"
    }
    
    //MARK: -
    
    func presentLoginScreen(delegate: ZPBaseLoginProviderLoginScreenDelegate?) {
       print("hello")
    }
    
    func hasAuthenticatedUser() -> Bool {
        return self.isAuthenticated()
    }
}
