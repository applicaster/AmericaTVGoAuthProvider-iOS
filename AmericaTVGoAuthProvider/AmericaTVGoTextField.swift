//
//  AmericaTVGoTextField.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/16/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit

class AmericaTVGoTextField: UITextField, UITextFieldDelegate {
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var togglePasswordVisibilityButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func awakeFromNib() {
        self.delegate = self
        
        if self.togglePasswordVisibilityButton != nil {
            self.togglePasswordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        }
        
        if self.lineView != nil {
            self.lineView.backgroundColor = UIColor.tvgoGrey
        }
    }
    
    deinit {
        self.delegate = nil
    }
    
    fileprivate func commonInit() {
        
    }
    
    @objc
    func togglePasswordVisibility(_ sender: UIButton) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        togglePasswordVisibilityButton.setTitle(self.isSecureTextEntry ? "Mostrar" : "Ocultar", for: .normal)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.lineView.backgroundColor = UIColor.tvgoLightOrgange
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.lineView.backgroundColor = UIColor.tvgoGrey
    }
}
