//
//  AmericaTVGoRegisterStep2PremiumViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/16/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit

let AmericaTVGoRegisterLaterNotification = Notification.Name("AmericaTVGoRegisterLaterNotification")

class AmericaTVGoRegisterStep2PremiumViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    var products = [AmericaTVGoProduct]()
    
    fileprivate var selectedIndex: Int?
    fileprivate var selectedContainerView: AmericaTVGoShadowBoxView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        products.append(AmericaTVGoProduct(identifier: "1000", duration: "1", unit: "año", oldPrice: "s/ 120", newPrice: "s/ 90"))
        products.append(AmericaTVGoProduct(identifier: "1001", duration: "6", unit: "meses", oldPrice: "s/ 60", newPrice: "s/ 50"))
        products.append(AmericaTVGoProduct(identifier: "1002", duration: "1", unit: "mes", oldPrice: " ", newPrice: "s/ 10"))
        
        productsCollectionView.register(UINib(nibName: "AmericaTVGoProductCollectionViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "productCell")
        
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
        
        productsCollectionView.reloadData()
    }

    @IBAction func handleGoBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleRegistration(_ sender: Any) {
        if let index = self.selectedIndex {
            let product = products[index]
            print("User selected \(product.timeDuration) \(product.timeUnit) @ \(product.newPrice)")
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
