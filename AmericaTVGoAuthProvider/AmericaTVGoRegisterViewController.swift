//
//  AmericaTVGoRegisterViewController.swift
//  AmericaTVGoAuthProvider-iOS
//
//  Created by Roi Kedarya on 17/07/2018.
//

import UIKit
import ApplicasterSDK

class AmericaTVGoRegisterViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hideRevealButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate:APAuthorizationClientDelegate?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, delegate:APAuthorizationClientDelegate?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func hideRevealButtonClicked(_ sender: Any) {
        if self.passwordTextField.isSecureTextEntry {
            self.hideRevealButton.setTitle("Ocultar", for: .normal)
            self.passwordTextField.isSecureTextEntry = false
        } else {
            self.hideRevealButton.setTitle("Mostar", for: .normal)
            self.passwordTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
        if self == topMostViewController {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        if let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty {
            self.activityIndicator.startAnimating()
            
            let manager = AmericaTVGoAPIManager.shared
            
            manager.registerUser(email: email, password: password, isPremium: true) { (success: Bool, token: String?, message: String?) in
                self.activityIndicator.stopAnimating()

                if success {
                    let alertViewController = UIAlertController(title: nil, message: message ?? "¡Registro Exitoso!", preferredStyle: .alert)
                    
                    alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { (_) -> Void in
                        self.dismiss(animated: true) {
                            if let aToken = token {
                                if let loginScreen = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal() as? AmericaTVGoLoginViewController {
                                    loginScreen.dismiss(animated: true) {
                                        self.delegate?.didFinishAuthorization!(withToken: aToken)
                                    }
                                }
                            }
                        }
                    })
                    
                    self.present(alertViewController, animated: true, completion: nil)
                    
                    
                    /*if let token = token as String? {
                        self.dismiss(animated: true) {
                            if let loginScreen = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal() as? AmericaTVGoLoginViewController {
                                loginScreen.dismiss(animated: true, completion: {
                                    self.delegate?.didFinishAuthorization!(withToken: token)
                                })
                            }
                        }
                    } else {
                        //no token - user didn't pay - go to payment screen with the itunes account and create a subscribtion item
                        if let userId = UserDefaults.standard.object(forKey: AmericaTVGoAPIManagerUserIDKey) {
                            
                        }
                    }*/
                } else {
                    let alertController = UIAlertController(title: nil, message: message ?? "Ocurrio un error.", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                        
                    })
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            let alertController = UIAlertController.init(title: nil,
                                                         message: "Por favor asegúrate de escribir un email y contraseña",
                                                         preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK", style: .default) { (_) in
                
            })
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
