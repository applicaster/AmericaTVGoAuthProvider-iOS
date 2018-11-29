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
    
    @IBOutlet weak var oldPriceLabel: AmericaTVGoStrikethroughLabel!
    @IBOutlet weak var newPriceLabel: UILabel!
    
    var selectHandler: ((_ selected: Bool) -> Void)?
    
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
        oldPriceLabel.text = product?.oldPrice ?? ""
        newPriceLabel.text = product?.newPrice ?? ""
    }

    func americaTVGoShadowBoxViewWillSelect(_ view: AmericaTVGoShadowBoxView) -> Bool {
        return true
    }
    
    func americaTVGoShadowBoxViewDidSelect(_ view: AmericaTVGoShadowBoxView) {
        self.selectHandler?(view.isSelected)
    }
}
