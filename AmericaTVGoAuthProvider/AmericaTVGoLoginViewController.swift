 //
//  AmericaTVGoLoginViewController.swift
//  ZappLoginPluginAmericaTVGO
//
//  Created by Roi Kedarya on 09/07/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import UIKit
import ApplicasterSDK
import MBProgressHUD

class AmericaTVGoLoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: AmericaTVGoTextField!
    @IBOutlet weak var passwordTextField: AmericaTVGoTextField!
    @IBOutlet weak var loginButton: UIButton!
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let _ = emailTextField.resignFirstResponder()
        let _ = passwordTextField.resignFirstResponder()
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
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        
        login(email: email, password: password)
    }
    
    fileprivate func login(email: String, password: String) {
        if !email.isEmpty && !password.isEmpty && AmericaTVGoUtils.validateEmail(email) {
            self.loginButton.isEnabled = false
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            let manager = AmericaTVGoAPIManager.shared
            
            manager.loginUser(email: email, password: password) { (success: Bool, token: String?, message: String?) in
                
                let user = AmericaTVGoIAPManager.shared.currentUser
                user.email = email
                user.password = password
                
                if success {
                    if let aToken = token, !aToken.isEmpty {
                        let alertController = UIAlertController(title: "", message: message ?? "¡Login Exitoso!", preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                            self.dismiss(animated: true) {
                                self.delegate?.didFinishAuthorization!(withToken:aToken)
                            }
                        })
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "", message: message ?? "¡No tiene suscripción activa!", preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                            let controller = AmericaTVGoIAPProductsViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
                            let navController = UINavigationController(rootViewController: controller)
                            navController.isNavigationBarHidden = true
                            
                            self.present(navController, animated: true, completion: nil)
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
                
                self.loginButton.isEnabled = true
                MBProgressHUD.hide(for: self.view, animated: true)
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
