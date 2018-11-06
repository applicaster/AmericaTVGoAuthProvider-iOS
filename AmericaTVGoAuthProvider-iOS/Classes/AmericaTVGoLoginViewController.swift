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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var hideRevealButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    private let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    private var delegate:APAuthorizationClientDelegate?
    
    @IBAction func hideRevealButtonClicked(_ sender: Any) {
        if self.passwordTextField.isSecureTextEntry {
            self.hideRevealButton.setTitle("Ocultar", for: .normal)
            self.passwordTextField.isSecureTextEntry = false
        } else {
            self.hideRevealButton.setTitle("Mostar", for: .normal)
            self.passwordTextField.isSecureTextEntry = true
        }
    }
   
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, andDelegate delegate:APAuthorizationClientDelegate?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        if let delegate = delegate {
            self.delegate = delegate
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
        let forgotPasswordViewController = AmericaTVGoForgotPasswordViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
        self.present(forgotPasswordViewController,
                     animated: true,
                     completion: nil)
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didCancelAuthorization!(false)
            let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
            if let playerViewController = topMostViewController as? APPlayerViewController{
                playerViewController.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        let registerViewController = AmericaTVGoRegisterViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder), delegate:delegate)
        //registerViewController.delegate = self.delegate
        self.present(registerViewController,
                     animated: true,
                     completion: nil)
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        if let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            email.count > 0,
            password.count > 0 {
            self.activityIndicator.startAnimating()
            
            AmericaTVGoLoginAPIManager.sharedInstance.loginUser(email: email,
                                                             password: password,
                                                             completion: { (success,token) in
                                                                self.activityIndicator.stopAnimating()
                                                                if success {
                                                                    if let token = token as String? {
                                                                        self.dismiss(animated: true) {
                                                                            self.delegate?.didFinishAuthorization!(withToken:token)
                                                                        }
                                                                    } else {
                                                                        //no token - user didn't pay - go to payment screen
                                                                        if let userId = UserDefaults.standard.object(forKey: AmericaTVGoLoginAPIManager.userIDKey) {
                                                                            if let purchaseVC = AmericaTVGoInAppPurchaseViewController.init(nibName: "AmericaTVGoInAppPurchaseViewController",
                                                                                                                                            bundle: Bundle(for: self.classForCoder)) as? UIViewController {
                                                                                let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
                                                                                topMostViewController?.present(purchaseVC, animated: true, completion: {
                                                                                    
                                                                                })
                                                                            }
                                                                        }
                                                                    }
                                                                }else {
                                                                    // Incorrect username or password
                                                                    let alertController = UIAlertController.init(title: self.appName,
                                                                                                                 message: "Correo o contraseña equivocada",
                                                                                                                 preferredStyle: .alert)
                                                                    alertController.addAction(UIAlertAction.init(title: "OK",
                                                                                                                 style: .default,
                                                                                                                 handler: { (action) in
                                                                                                                    alertController.dismiss(animated: true, completion: nil)
                                                                    }))
                                                                    self.present(alertController,
                                                                                 animated: true,
                                                                                 completion: nil)
                                                                }
            })
        } else {
            // Please make sure to fill email and password
            let alertController = UIAlertController.init(title: self.appName,
                                                         message: "Por favor asegúrate de escribir tu email y contraseña",
                                                         preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK",
                                                         style: .default,
                                                         handler: { (action) in
                                                            alertController.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController,
                         animated: true,
                         completion: nil)
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UI_USER_INTERFACE_IDIOM() == .pad ? .landscape  : .portrait
    }
    
    open override var shouldAutorotate: Bool {
        return true
    }
}
