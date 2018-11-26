//
//  AmericaTVGoRegisterStep1ViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/16/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit

class AmericaTVGoRegisterStep1ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        } else if !(termsButton.isSelected && privacyButton.isSelected) {
            alertMessage = "Por favor acepte los términos y condiciones y la polica de privacidad."
        }
        
        if !alertMessage.isEmpty {
            let alertController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        let controller = AmericaTVGoRegisterStep2PremiumViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
