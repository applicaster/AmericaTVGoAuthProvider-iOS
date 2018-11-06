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
        
    }
}
