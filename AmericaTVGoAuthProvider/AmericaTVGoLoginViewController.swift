 //
//  AmericaTVGoLoginViewController.swift
//  ZappLoginPluginAmericaTVGO
//
//  Created by Roi Kedarya on 09/07/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import UIKit
import ApplicasterSDK

class AmericaTVGoLoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: AmericaTVGoTextField!
    @IBOutlet weak var passwordTextField: AmericaTVGoTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    private var delegate:APAuthorizationClientDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = emailTextField.becomeFirstResponder()
    }
   
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, andDelegate delegate:APAuthorizationClientDelegate?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let user = AmericaTVGoIAPManager.shared.currentUser
        
        emailTextField.text = user.email
        
        if let password = APKeychain.getStringForKey(user.id) {
            passwordTextField.text = password
        }
    }
    
    // MARK: -
    
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
        let forgotPasswordViewController = AmericaTVGoForgotPasswordViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
        self.present(forgotPasswordViewController,
                     animated: true,
                     completion: nil)
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        handleDismiss()
    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        let controller = AmericaTVGoRegisterAccountPickerViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        
        if let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal() {
            topMostViewController.present(navController, animated: true, completion: nil)
        } else {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        if let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty, AmericaTVGoUtils.validateEmail(email) {
            self.activityIndicator.startAnimating()
            
            let manager = AmericaTVGoAPIManager.shared
            
            manager.loginUser(email: email, password: password) { (success: Bool, token: String?, message: String?) in
                self.activityIndicator.stopAnimating()
                
                let user = AmericaTVGoIAPManager.shared.currentUser
                user.email = email
                user.password = password
                
                if success {
                    if let aToken = token, !aToken.isEmpty {
                        let alertController = UIAlertController(title: self.appName, message: message ?? "¡Login Exitoso!", preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                            self.dismiss(animated: true) {
                                self.delegate?.didFinishAuthorization!(withToken:aToken)
                            }
                        })
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: self.appName, message: message ?? "¡No tiene suscripción activa!", preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                            let controller = AmericaTVGoIAPProductsViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
                            let navController = UINavigationController(rootViewController: controller)
                            navController.isNavigationBarHidden = true
                            
                            self.present(navController, animated: true, completion: nil)
                            
                            //self.dismiss(animated: true) {
                                //no token - user didn't pay - go to payment screen
                                //if let userId = UserDefaults.standard.object(forKey: AmericaTVGoAPIManagerUserIDKey) {
                                    /*let purchaseVC = AmericaTVGoInAppPurchaseViewController(nibName: "AmericaTVGoInAppPurchaseViewController", bundle: Bundle(for: self.classForCoder))
                                
                                    if let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal() {
                                        topMostViewController.present(purchaseVC, animated: true, completion: {
                                            
                                        })
                                    } else {
                                        self.present(purchaseVC, animated: true, completion: nil)
                                    }*/
                                //}
                            //}
                        })
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                } else {
                    // Incorrect username or password
                    let alertController = UIAlertController.init(title: self.appName,
                                                                 message: message ?? "Correo o contraseña equivocada",
                                                                 preferredStyle: .alert)
                    alertController.addAction(UIAlertAction.init(title: "OK", style: .default) { (_) in
                        
                    })

                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            // Please make sure to fill email and password
            let alertController = UIAlertController.init(title: self.appName,
                                                         message: "Por favor asegúrate de escribir tu email y contraseña",
                                                         preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default) { (_) in
                
            })
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: -
    
    fileprivate func handleDismiss() {
        self.dismiss(animated: true) {
            let user = AmericaTVGoIAPManager.shared.currentUser
            
            if user.token.isEmpty {
                self.delegate?.didCancelAuthorization!(false)
            } else {
                self.delegate?.didFinishAuthorization!(withToken: user.token)
            }
            
            let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
            if let viewController = topMostViewController as? AmericaTVGoLoginViewController {
                viewController.dismiss(animated: true)
            }
        }
    }
    
    // MARK: -
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UI_USER_INTERFACE_IDIOM() == .pad ? .landscape  : .portrait
    }
    
    open override var shouldAutorotate: Bool {
        return true
    }
}
