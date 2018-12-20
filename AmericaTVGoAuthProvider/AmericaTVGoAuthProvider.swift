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

let AmericaTVGoRegisterLaterNotification = Notification.Name("AmericaTVGoRegisterLaterNotification")

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
        
        if let providerID = authProvider.uniqueID {
            UserDefaults.standard.set(providerID, forKey: AmericaTVGoAPIManagerAuthProviderIDKey)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(registerLaterNotification(_:)), name: AmericaTVGoRegisterLaterNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AmericaTVGoRegisterLaterNotification, object: nil)
    }
    
    // MARK: -
    
    func login(userID: String, completion: @escaping ((ZPLoginOperationStatus) -> Void)) {
        self.performingLogin = true
        
        AmericaTVGoAPIManager.shared.getUser(id: userID) { (_ success: Bool, _ token: String?, _ message: String?) in
            let user = AmericaTVGoIAPManager.shared.currentUser
            
            if let userPassword = APKeychain.getStringForKey(userID) {
                AmericaTVGoAPIManager.shared.loginUser(email: user.email, password: userPassword) { (success: Bool, token: String?, message: String?) in
                    AmericaTVGoAPIManager.updateUserDefaultsFromCurrentUser()
                    
                    self.performingLogin = false
                    
                    AmericaTVGoAPIManager.shared.updateToken(token ?? "")
                    
                    completion(.completedSuccessfully)
                }
            } else {
                self.performingLogin = false
                
                AmericaTVGoAPIManager.shared.updateToken("")
                
                completion(.completedSuccessfully)
            }
        }
    }
    
    func logout(_ completion: @escaping ((ZPLoginOperationStatus) -> Void)) {
        let user = AmericaTVGoIAPManager.shared.currentUser
        var message = ""
        
        if user.isLoggedIn() {
            AmericaTVGoAPIManager.clearUserDefaultsFromCurrentUser()
            AmericaTVGoAPIManager.shared.updateToken("")
            APKeychain.deleteString(forKey: user.id)
            
            user.logout()
            
            message = "¡La sesión se ha cerrado!"
        } else {
            message = "No hay sesión activa."
        }
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
        topMostViewController?.present(alertController, animated: true, completion: nil)
        
        completion(.cancelled)
    }
    
    func isAuthenticated() -> Bool {
        if let token = UserDefaults.standard.object(forKey: AmericaTVGoAPIManagerUserTokenKey) as? String, !token.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    // MARK: APAuthorizationClient
    
    func startAuthorizationProcess() {
        let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
        let viewController: UIViewController
        
        let user = AmericaTVGoIAPManager.shared.currentUser
        
        if user.id.isEmpty {
            viewController = AmericaTVGoLoginViewController.init(nibName: "AmericaTVGoLoginViewController", bundle: Bundle(for: type(of: self)), andDelegate: delegate)
        } else {
            if user.isLoggedIn() && user.token.isEmpty {
                viewController = AmericaTVGoIAPProductsViewController.init(nibName: "AmericaTVGoIAPProductsViewController", bundle: Bundle(for: type(of: self)))
            } else {
                // should probably not happen
                viewController = AmericaTVGoRegistrationFinishedViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
            }
        }
        
        topMostViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func handleUrlScheme(_ params: NSDictionary) {
        if let type = params["type"] as? String, type == "auth_provider" {
            if let action = params["action"] as? String, action == "logout" {
                self.logout { (status) in
                    // Nothing to do
                }
            }
        } else {
            let expectedUrlSchemeNameParam = self.urlSchemeName()
            let nameParam = params["name"] as? String
            
            if expectedUrlSchemeNameParam.isEmpty || nameParam == expectedUrlSchemeNameParam {
                if let userID = UserDefaults.standard.object(forKey: AmericaTVGoAPIManagerUserIDKey) as? String {
                    self.login(userID: userID) { (status) in
                        // Nothing to do
                    }
                }
            }
        }
    }
    
    //MARK: ZPAppLoadingHookProtocol
    
    func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?) {
        if let userID = UserDefaults.standard.object(forKey: AmericaTVGoAPIManagerUserIDKey) as? String, !userID.isEmpty {
            self.login(userID: userID) { (status) in
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    //MARK: ZPBaseLoginProviderFlowHandler
    func urlSchemeName() -> String {
        return "americatvgo"
    }
    
    //MARK: -
    
    func presentLoginScreen(delegate: ZPBaseLoginProviderLoginScreenDelegate?) {
       
    }
    
    func hasAuthenticatedUser() -> Bool {
        return self.isAuthenticated()
    }
    
    // MARK: -
    
    @objc
    func registerLaterNotification(_ sender: Notification) {
        if let controller = sender.userInfo?["sender"] as? UIViewController {
            controller.modalTransitionStyle = .crossDissolve
            
            controller.dismiss(animated: false) {
                let user = AmericaTVGoIAPManager.shared.currentUser
                
                if user.token.isEmpty {
                    self.delegate?.didCancelAuthorization!(false)
                } else {
                    self.delegate?.didFinishAuthorization!(withToken: user.token)
                }
                
                let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
                if let viewController = topMostViewController {
                    viewController.dismiss(animated: true)
                }
            }
        }
    }
}
