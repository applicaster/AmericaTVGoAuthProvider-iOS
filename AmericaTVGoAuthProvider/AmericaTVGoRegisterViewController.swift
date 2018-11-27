//
//  AmericaTVGoRegisterStep1ViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/16/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit
import ApplicasterSDK

class AmericaTVGoRegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = AmericaTVGoIAPManager.shared.currentUser
        emailTextField.text = user.email
        passwordTextField.text = user.password
    }

    // MARK: -
    @IBAction func handleGoBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func acceptLegal(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func handleRegistration(_ sender: Any) {
        var alertMessage = ""
        
        if let email = emailTextField.text, let password = passwordTextField.text, email.isEmpty || password.isEmpty {
            alertMessage = "Los campos de correo y contraseña no pueden estar vacios."
        } else if !AmericaTVGoUtils.validateEmail(emailTextField.text ?? "") {
            alertMessage = "El formato del email no es correcto."
        } else if !(termsButton.isSelected && privacyButton.isSelected) {
            alertMessage = "Por favor acepte los términos y condiciones y la polica de privacidad."
        }
        
        if !alertMessage.isEmpty {
            let alertController = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {
            let user = AmericaTVGoIAPManager.shared.currentUser
            user.email = emailTextField.text!
            user.password = passwordTextField.text!
            
            if user.isPremium {
                let controller = AmericaTVGoIAPProductsViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                handleRegistration()
            }
        }
    }
    
    func handleRegistration() {
        let user = AmericaTVGoIAPManager.shared.currentUser
        
        if !(user.email.isEmpty || user.password.isEmpty) {
            self.progressIndicator.startAnimating()
            
            let manager = AmericaTVGoAPIManager.shared
            
            manager.registerUser(email: user.email, password: user.password, isPremium: user.isPremium) { (success: Bool, token: String?, message: String?) in
                DispatchQueue.main.async {
                    self.progressIndicator.stopAnimating()
                    
                    if success {
                        if let aToken = token {
                            user.token = aToken
                        }
                        
                        let bundle = Bundle(for: self.classForCoder)
                        let controller = AmericaTVGoRegistrationFinishedViewController.init(nibName: nil, bundle: bundle)
                        self.navigationController?.pushViewController(controller, animated: true)
                    } else {
                        let alertController = UIAlertController(title: nil, message: message ?? "Ocurrio un error.", preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                            
                        })
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
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
