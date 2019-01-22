//
//  AmericaTVGoRegistrationFinishedViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/27/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit
import ApplicasterSDK

class AmericaTVGoRegistrationFinishedViewController: UIViewController {
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = AmericaTVGoIAPManager.shared.currentUser
        if !user.isPremium {
            if let text = detailsLabel.text {
                let message = "Te hemos enviado a tu correo un mensaje para que puedas confirmar tu cuenta."
                
                detailsLabel.text = text+"\n\n"+message
            }
        }
    }

    @IBAction func handleContinue(_ sender: Any) {
        NotificationCenter.default.post(name: AmericaTVGoRegisterLaterNotification, object: nil, userInfo: ["sender": self])
    }

}
