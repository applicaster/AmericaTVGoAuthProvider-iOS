//
//  AmericaTVGoForgotPasswordViewController.swift
//  AmericaTVGoAuthProvider-iOS
//
//  Created by Roi Kedarya on 17/07/2018.
//

import ApplicasterSDK

class AmericaTVGoForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: AmericaTVGoTextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let _ = emailTextField.resignFirstResponder()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        if let email = self.emailTextField.text,
            !email.isEmpty {
            self.sendButton.isEnabled = false
            AmericaTVGoUtils.shared.showHUD(self.view)
            
            let manager = AmericaTVGoAPIManager.shared
            
            manager.forgotPassword(email: email) { (success: Bool, message: String?) in
                if success {
                    let alertViewController = UIAlertController(title: "", message: message ?? "¡Recuperacion de contraseña exitoso!", preferredStyle: .alert)
                    
                    alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) -> Void in
                        self.dismiss(animated: true) {
                            
                        }
                    }))
                    
                    self.present(alertViewController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "", message: message ?? "Ocurrio un error.", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                self.sendButton.isEnabled = true
                AmericaTVGoUtils.shared.hideHUD()
            }
        } else {
            let alertController = UIAlertController(title: "",
                                                    message: "Por favor asegúrate de escribir tu email.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            self.sendButton.isEnabled = true
        }
    }
}
