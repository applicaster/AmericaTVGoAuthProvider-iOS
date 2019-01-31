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
    @IBOutlet weak var timeDurationLabel: UILabel!
    
    @IBOutlet weak var timeUnitLabel: UILabel!
    
    @IBOutlet weak var oldPriceLabel: UILabel!
    @IBOutlet weak var newPriceLabel: UILabel!
    
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
        timeDurationLabel.text = product?.timeDuration ?? ""
        timeUnitLabel.text = product?.timeUnit ?? ""
        
        /*if let oldPrice = product?.oldPrice, !oldPrice.isEmpty {
            oldPriceLabel.text = oldPrice
        } else {
            oldPriceLabel.text = ""
        }*/
        
        if let newPrice = product?.newPrice {
            newPriceLabel.text = newPrice
        } else {
            newPriceLabel.text = ""
        }
        
        oldPriceLabel.text = product?.promotionText ?? ""
    }

    func americaTVGoShadowBoxViewWillSelect(_ view: AmericaTVGoShadowBoxView) -> Bool {
        return true
    }
    
    func americaTVGoShadowBoxViewDidSelect(_ view: AmericaTVGoShadowBoxView) {
        
    }
}
