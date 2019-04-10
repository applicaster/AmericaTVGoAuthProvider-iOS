//
//  AmericaTVGoShadowBoxView.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/13/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit

protocol AmericaTVGoShadowBoxViewDelegate {
    func americaTVGoShadowBoxViewWillSelect(_ view: AmericaTVGoShadowBoxView) -> Bool
    func americaTVGoShadowBoxViewDidSelect(_ view: AmericaTVGoShadowBoxView)
}

fileprivate let kAmericaTVGoShadowBoxViewStrokeWidth = CGFloat(4.0)

class AmericaTVGoShadowBoxView: UIView {
    var delegate: AmericaTVGoShadowBoxViewDelegate?
    
    var isSelected = false {
        didSet {
            if oldValue != isSelected {
                self.update()
            }
        }
    }
    
    fileprivate var checkboxImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        update()
    }
    
    func update() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.2
        self.layer.cornerRadius = 5.0
        
        if isSelected {
            self.layer.borderWidth = kAmericaTVGoShadowBoxViewStrokeWidth
            self.layer.borderColor = UIColor.tvgoDarkOrange?.cgColor
            
            if let path = Bundle(for: self.classForCoder).path(forResource: "checkbox_on", ofType: "png") {
                let checkboxOnImage = UIImage(contentsOfFile: path)
                let checkboxImageView = UIImageView(image: checkboxOnImage)
                checkboxImageView.translatesAutoresizingMaskIntoConstraints = false
                
                self.addSubview(checkboxImageView)
                
                self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[checkboxImageView]-0-|", options: [], metrics: nil, views: ["checkboxImageView": checkboxImageView]))
                self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[checkboxImageView]", options: [], metrics: nil, views: ["checkboxImageView": checkboxImageView]))
                
                self.checkboxImageView = checkboxImageView
            }
        } else {
            self.layer.borderWidth = 0
            self.checkboxImageView?.image = nil
            self.checkboxImageView?.removeFromSuperview()
            self.checkboxImageView = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let canSelect = self.delegate?.americaTVGoShadowBoxViewWillSelect(self), canSelect == true {
            self.isSelected = !self.isSelected
            self.delegate?.americaTVGoShadowBoxViewDidSelect(self)
        } else {
            var buttons = [UIButton]()
            
            for subview in self.subviews {
                if subview is UIButton {
                    buttons.append(subview as! UIButton)
                }
            }
            
            if buttons.count == 1 {
                let button = buttons.first!
                if button.isEnabled {
                    button.sendActions(for: .touchUpInside)
                }
            }
        }
    }

}
