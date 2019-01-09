//
//  AmericaTVGoUtils.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/26/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import Foundation
import MBProgressHUD

class AmericaTVGoUtils {
    static let shared = AmericaTVGoUtils()
    
    fileprivate var hud: MBProgressHUD?
    
    func showHUD(_ view: UIView) {
        if self.hud != nil {
            return
        }
        
        let hud = MBProgressHUD(view: view)
        
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = UIColor(white: 0.0, alpha: 0.6)
        
        view.addSubview(hud)
        
        hud.show(animated: true)
        
        self.hud = hud
    }
    
    func hideHUD() {
        guard let hud = self.hud else {
            return
        }
        
        hud.hide(animated: true)
        
        self.hud = nil
    }
    
    // MARK: -
    
    class func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
