//
//  AmericaTVGoRegisterStep0ViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/15/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit

class AmericaTVGoRegisterAccountPickerViewController: UIViewController, AmericaTVGoShadowBoxViewDelegate {

    @IBOutlet weak var basicBoxView: AmericaTVGoShadowBoxView!
    @IBOutlet weak var premiumBoxView: AmericaTVGoShadowBoxView!
    
    fileprivate var selectedView: AmericaTVGoShadowBoxView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.basicBoxView.delegate = self
        self.premiumBoxView.delegate = self
        
        self.premiumBoxView.isSelected = true
        self.selectedView = self.premiumBoxView
    }

    @IBAction func handleGoBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueToNextStep(_ sender: Any) {
        var controller: UIViewController!
        
        if basicBoxView.isSelected {
            AmericaTVGoIAPManager.shared.currentUser.isPremium = false
            controller = AmericaTVGoRegisterViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
        } else if premiumBoxView.isSelected {
            AmericaTVGoIAPManager.shared.currentUser.isPremium = true
            controller = AmericaTVGoRegisterPremiumViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
        } else {
            let alertController = UIAlertController(title: "", message: "Por favor seleccione una opción.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        if controller != nil {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    // MARK: -
    
    func americaTVGoShadowBoxViewWillSelect(_ view: AmericaTVGoShadowBoxView) -> Bool {
        if view == self.selectedView {
            return false
        }
        
        self.selectedView = view
        
        return true
    }
    
    func americaTVGoShadowBoxViewDidSelect(_ view: AmericaTVGoShadowBoxView) {
        switch view {
        case basicBoxView:
            premiumBoxView.isSelected = false
        case premiumBoxView:
            basicBoxView.isSelected = false
        default:
            break
        }
    }
}
