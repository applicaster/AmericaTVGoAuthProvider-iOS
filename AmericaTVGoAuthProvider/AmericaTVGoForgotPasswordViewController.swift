//
//  AmericaTVGoForgotPasswordViewController.swift
//  AmericaTVGoAuthProvider-iOS
//
//  Created by Roi Kedarya on 17/07/2018.
//

import ApplicasterSDK

class AmericaTVGoForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
        if self == topMostViewController {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if let email = self.emailTextField.text,
            !email.isEmpty {
            self.activityIndicator.startAnimating()
            
            let manager = AmericaTVGoAPIManager.shared
            
            manager.forgotPassword(email: email) { (success: Bool, message: String?) in
                self.activityIndicator.stopAnimating()
                if success {
                    let alertViewController = UIAlertController(title: nil, message: message ?? "¡Recuperacion de contraseña exitoso!", preferredStyle: .alert)
                    
                    alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) -> Void in
                        self.dismiss(animated: true) {
                            
                        }
                    }))
                    
                    self.present(alertViewController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: nil, message: message ?? "Ocurrio un error.", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        //self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            let alertController = UIAlertController.init(title: nil,
                                                         message: "Por favor asegúrate de escribir tu email.",
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
}
