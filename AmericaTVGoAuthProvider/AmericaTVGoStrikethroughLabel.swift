//
//  AmericaTVGoStrikethroughLabel.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/20/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit

class AmericaTVGoStrikethroughLabel: UILabel {
    override var text: String? {
        set {
            if let txt = newValue, !txt.isEmpty {
                let attrString = NSAttributedString(string: txt, attributes: [NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: self.textColor])
                self.attributedText = attrString
            } else {
                self.attributedText = NSAttributedString(string: "")
            }
        }
        get {
            return self.attributedText?.string
        }
    }
}
