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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func handleContinue(_ sender: Any) {
        NotificationCenter.default.post(name: AmericaTVGoRegisterLaterNotification, object: nil, userInfo: ["sender": self])
    }

}
