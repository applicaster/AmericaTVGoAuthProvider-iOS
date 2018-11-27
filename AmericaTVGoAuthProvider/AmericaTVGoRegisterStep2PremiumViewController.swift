//
//  AmericaTVGoRegisterStep2PremiumViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/16/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit
import StoreKit

let AmericaTVGoRegisterLaterNotification = Notification.Name("AmericaTVGoRegisterLaterNotification")

class AmericaTVGoRegisterStep2PremiumViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var productsCollectionViewHeightConstraint: NSLayoutConstraint!
    var products = [AmericaTVGoProduct]()
    
    fileprivate var selectedIndex: Int?
    fileprivate var selectedContainerView: AmericaTVGoShadowBoxView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsCollectionView.register(UINib(nibName: "AmericaTVGoProductCollectionViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "productCell")
        
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
        
        productsCollectionView.reloadData()
        
        productsCollectionViewHeightConstraint.constant = productsCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        progressIndicator.startAnimating()
        AmericaTVGoIAPManager.shared.retrieveRemoteProducts { (newProducts) in
            self.products = newProducts
            self.progressIndicator.stopAnimating()
            self.productsCollectionView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func handleGoBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleRegistration(_ sender: Any) {
        if let index = self.selectedIndex {
            let product = products[index]
            let user = AmericaTVGoIAPManager.shared.currentUser
            user.product = product
            
            let message = "User selected:\n\(product.timeDuration)\n\(product.timeUnit) @ \(product.newPrice)"
            
            let alertController = UIAlertController(title: "IAP Flow...", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            let alertController = UIAlertController(title: nil, message: "Por favor seleccione una promoción.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func handleSubscribeLater(_ sender: Any) {
        NotificationCenter.default.post(name: AmericaTVGoRegisterLaterNotification, object: nil, userInfo: ["sender": self])
    }
    
    // MARK: -
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! AmericaTVGoProductCollectionViewCell
        
        let product = products[indexPath.row]
        
        cell.product = product
        
        cell.selectHandler = { (_ selected: Bool) -> Void in
            if self.selectedContainerView != cell.containerView {
                self.selectedContainerView?.isSelected = false
            }
            self.selectedContainerView = selected ? cell.containerView : nil
            self.selectedIndex = selected ? indexPath.row : nil
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let newWidth = (collectionView.width-8.0-8.0)/3.0
        return CGSize(width: newWidth, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
}
