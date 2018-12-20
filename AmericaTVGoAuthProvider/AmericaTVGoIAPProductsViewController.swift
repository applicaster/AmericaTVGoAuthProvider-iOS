//
//  AmericaTVGoIAPProductsViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/16/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit
import StoreKit

class AmericaTVGoIAPProductsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var productsCollectionViewHeightConstraint: NSLayoutConstraint!
    var products = [AmericaTVGoProduct]()
    
    fileprivate var selectedContainerView: AmericaTVGoShadowBoxView?
    fileprivate var selectedCell: AmericaTVGoProductCollectionViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsCollectionView.register(UINib(nibName: "AmericaTVGoProductCollectionViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "productCell")
        
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
        
        progressIndicator.startAnimating()
        continueButton.isEnabled = false
        
        AmericaTVGoIAPManager.shared.retrieveRemoteProducts { (newProducts) in
            self.products = newProducts
            self.progressIndicator.stopAnimating()
            self.productsCollectionView.reloadData()
            
            if let error = AmericaTVGoIAPManager.shared.requestError {
                let alertController = UIAlertController(title: "Ocurrio un error!", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.continueButton.isEnabled = true
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func handleGoBack(_ sender: Any) {
        if let navController = self.navigationController {
            if navController.topViewController == self {
                let user = AmericaTVGoIAPManager.shared.currentUser
                
                if user.id.isEmpty {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    NotificationCenter.default.post(name: AmericaTVGoRegisterLaterNotification, object: nil, userInfo: ["sender": self])
                }
            } else {
                navController.popViewController(animated: true)
            }
        } else {
            NotificationCenter.default.post(name: AmericaTVGoRegisterLaterNotification, object: nil, userInfo: ["sender": self])
        }
    }
    
    @IBAction func handleRegistration(_ sender: Any) {
        guard let selectedCell = self.selectedCell else {
            let alertController = UIAlertController(title: nil, message: "Por favor seleccione una promoción.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let indexPath = self.productsCollectionView.indexPath(for: selectedCell) else {
            return
        }
        
        let product = products[indexPath.row]
        
        if !AmericaTVGoIAPManager.shared.purchasesAllowed {
            let message = "No es posible hacer la compra de: \(product.identifier)"
            
            let alertController = UIAlertController(title: "Ocurrió un error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)

            return
        }
        
        let user = AmericaTVGoIAPManager.shared.currentUser
        user.product = product
        
        self.continueButton.isEnabled = false
        
        if let iapProduct = AmericaTVGoIAPManager.shared.iapProductWithIdentifier(product.identifier) {
            AmericaTVGoIAPManager.shared.submitProduct(iapProduct) { (_ success: Bool, transaction: SKPaymentTransaction) in
                if success {
                    AmericaTVGoAPIManager.shared.registerPurchaseForUser(userID: AmericaTVGoIAPManager.shared.currentUser.id, packageName: transaction.transactionIdentifier ?? "", subscriptionID: product.identifier, token: "") { (success: Bool, token: String?, message: String?) in
                        if success {
                            AmericaTVGoAPIManager.shared.updateToken(token ?? AmericaTVGoAPIManagaerInvalidToken)
                            let alertController = UIAlertController(title: nil, message: message ?? "¡La compra fue exitosa!", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                let controller = AmericaTVGoRegistrationFinishedViewController.init(nibName: nil, bundle: Bundle(for: self.classForCoder))
                                self.navigationController?.pushViewController(controller, animated: true)
                            }))
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: nil, message: message ?? "¡La compra no fue exitosa!", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                
                            }))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        self.continueButton.isEnabled = true
                    }
                } else {
                    let alertController = UIAlertController(title: "Ocurrió un error", message: transaction.error?.localizedDescription ?? "La transacción no se pudo completar exitosamente.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    self.continueButton.isEnabled = true
                }
            }
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
        
        if indexPath.row == 0 && self.selectedCell == nil {
            self.selectCell(cell)
            cell.containerView.isSelected = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.productsCollectionView.cellForItem(at: indexPath) as? AmericaTVGoProductCollectionViewCell {
            selectCell(cell)
        }
    }
    
    fileprivate func selectCell(_ cell: AmericaTVGoProductCollectionViewCell) {
        if self.selectedContainerView != cell.containerView {
            self.selectedContainerView?.isSelected = false
        }
        self.selectedContainerView = cell.containerView
        self.selectedCell = cell
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
    
    // MARK: -
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UI_USER_INTERFACE_IDIOM() == .pad ? .landscape  : .portrait
    }
    
    open override var shouldAutorotate: Bool {
        return true
    }
}
