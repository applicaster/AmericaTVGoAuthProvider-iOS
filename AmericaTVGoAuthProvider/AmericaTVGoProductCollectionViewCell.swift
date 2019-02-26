//
//  AmericaTvGoProductCollectionViewCell.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/21/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit

class AmericaTVGoProductCollectionViewCell: UICollectionViewCell, AmericaTVGoShadowBoxViewDelegate {
    @IBOutlet weak var containerView: AmericaTVGoShadowBoxView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var newPriceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var extraLabel: UILabel!
    
    
    var product: AmericaTVGoProduct? {
        didSet {
            update()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.delegate = self
        
        update()
    }
    
    func update() {
        var timeText = ""
        
        if let value = product?.timeDuration {
            timeText += value
        }
        
        if let value = product?.timeUnit {
            if !timeText.isEmpty {
                timeText += " "
            }
            timeText += value
        }
        
        if timeText.isEmpty {
            timeLabel.text = ""
        } else {
            timeLabel.text = timeText
        }
        
        if let newPrice = product?.newPrice {
            newPriceLabel.text = newPrice.uppercased()
        } else {
            newPriceLabel.text = ""
        }
        
        if let value = product?.promotionText, !value.isEmpty {
            extraLabel.text = value
            extraLabel.isHidden = false
        } else {
            extraLabel.isHidden = true
        }
        
    }

    func americaTVGoShadowBoxViewWillSelect(_ view: AmericaTVGoShadowBoxView) -> Bool {
        return true
    }
    
    func americaTVGoShadowBoxViewDidSelect(_ view: AmericaTVGoShadowBoxView) {
        
    }
}
