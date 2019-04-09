//
//  AmericaTVGoIAPProductsViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 11/16/18.
//  Copyright © 2018 applicaster. All rights reserved.
//

import UIKit
import StoreKit
import MBProgressHUD
import TTTAttributedLabel

fileprivate let kTermsSearchText = "Términos y condiciones"
fileprivate let kPrivacySearchText = "Políticas de privacidad"

class AmericaTVGoIAPProductsViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SKRequestDelegate, TTTAttributedLabelDelegate {
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var iapDescriptionLabel: TTTAttributedLabel!
    @IBOutlet weak var productsCollectionViewHeightConstraint: NSLayoutConstraint!
    var products = [AmericaTVGoProduct]()
    
    fileprivate var selectedContainerView: AmericaTVGoShadowBoxView?
    fileprivate var selectedCell: AmericaTVGoProductCollectionViewCell?
    
    fileprivate var currentTransaction: SKPaymentTransaction?
    fileprivate var currentProduct: SKProduct?
    fileprivate var currentID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsCollectionView.register(UINib(nibName: "AmericaTVGoProductCollectionViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "productCell")
        
        productsCollectionView.delegate = self
        productsCollectionView.dataSource = self
        
        continueButton.isEnabled = false
        
        updateLabel()
        
        AmericaTVGoUtils.shared.showHUD(self.view)
        
        AmericaTVGoIAPManager.shared.retrieveRemoteProducts { (newProducts) in
            self.products = newProducts
            self.productsCollectionView.reloadData()
            
            if let error = AmericaTVGoIAPManager.shared.requestError {
                let alertController = UIAlertController(title: "Ocurrio un error!", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.continueButton.isEnabled = true
            }
            
            AmericaTVGoUtils.shared.hideHUD()
            
            self.productsCollectionViewHeightConstraint.constant = self.productsCollectionView.contentSize.height
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    fileprivate func updateLabel() {
        let color = UIColor(red: 204.0/255.0, green: 83.0/255.0, blue: 67.0/255.0, alpha: 1.0)
        let linkAttributes = [kCTForegroundColorAttributeName: color.cgColor]
        iapDescriptionLabel.linkAttributes = linkAttributes as [AnyHashable : Any]
        iapDescriptionLabel.activeLinkAttributes = linkAttributes as [AnyHashable : Any]
        iapDescriptionLabel.inactiveLinkAttributes = linkAttributes as [AnyHashable : Any]
        
        let tcURL = URL(string: "https://tvgo.americatv.com.pe/terminos-condiciones")!
        let ppURL = URL(string: "https://tvgo.americatv.com.pe/politicas-de-privacidad")!
        let string = iapDescriptionLabel.text as! NSString
        
        let tcRange = string.range(of: kTermsSearchText)
        if tcRange.location != NSNotFound {
            self.iapDescriptionLabel.addLink(to: tcURL, with: tcRange)
        }
        
        let ppRange = string.range(of: kPrivacySearchText)
        if ppRange.location != NSNotFound {
            self.iapDescriptionLabel.addLink(to: ppURL, with: ppRange)
        }
        
        self.iapDescriptionLabel.delegate = self
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
            self.showSimpleAlert(title: "", message: "Por favor seleccione una promoción.") {
                
            }
            return
        }
        
        guard let indexPath = self.productsCollectionView.indexPath(for: selectedCell) else {
            return
        }
        
        let product = products[indexPath.row]
        
        if !AmericaTVGoIAPManager.shared.purchasesAllowed {
            let message = "Para poder comprar \(product.identifier), es necesario que el dispositivo tenga permiso de hacer compras."
            
            self.showSimpleAlert(title: "No se pueden realizar compras", message: message) {
                
            }
            return
        }
        
        let user = AmericaTVGoIAPManager.shared.currentUser
        user.product = product
        
        self.continueButton.isEnabled = false
        AmericaTVGoUtils.shared.showHUD(self.view)
        
        if let iapProduct = AmericaTVGoIAPManager.shared.iapProductWithIdentifier(product.identifier) {
            AmericaTVGoIAPManager.shared.submitProduct(iapProduct) { (_ success: Bool, transaction: SKPaymentTransaction) in
                if success {
                    if let _ = AmericaTVGoIAPManager.shared.receiptDataString {
                        self.validateTransaction(transaction, product: iapProduct, id: product.identifier)
                    } else {
                        self.currentTransaction = transaction
                        self.currentProduct = iapProduct
                        self.currentID = product.identifier
                        
                        let refreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
                        refreshRequest.delegate = self
                        refreshRequest.start()
                    }
                } else {
                    if let _ = AmericaTVGoIAPManager.shared.receiptDataString {
                        self.validateTransaction(transaction, product: iapProduct, id: product.identifier)
                    } else {
                        NotificationCenter.default.post(name: AmericaTVGoCancelAuthenticationNotification, object: nil, userInfo: nil)
                        
                        var message = ""
                        
                        if let error = transaction.error?.localizedDescription {
                            message = "Se produjo el siguiente error: \(error)."
                        } else {
                            message = "Hubo un problema al hacer la compra por iTunes."
                        }
                        
                        self.showSimpleAlert(title: "La compra no fue exitosa", message: message, completion: {
                            
                        })
                    }
                    
                    self.continueButton.isEnabled = true
                    AmericaTVGoUtils.shared.hideHUD()
                }
            }
        }
        
    }
    
    func validateTransaction(_ transaction: SKPaymentTransaction, product: SKProduct, id: String) {
        let receiptDataString = AmericaTVGoIAPManager.shared.receiptDataString ?? ""
        
        AmericaTVGoAPIManager.shared.registerPurchaseForUser(userID: AmericaTVGoIAPManager.shared.currentUser.id, packageName: transaction.transactionIdentifier ?? "", subscriptionID: id, token: receiptDataString) { (success: Bool, token: String?, message: String?) in
            if success {
                AmericaTVGoAPIManager.shared.updateToken(token ?? "")
                
                NotificationCenter.default.post(name: AmericaTVGoRegisterLaterNotification, object: nil, userInfo: nil)
                
                self.showSimpleAlert(title: "", message: message ?? "¡La compra fue exitosa!", completion: {
                    
                })
            } else {
                NotificationCenter.default.post(name: AmericaTVGoCancelAuthenticationNotification, object: nil, userInfo: nil)
                
                self.showSimpleAlert(title: "", message: message ?? "¡No se pudo verificar la compra!", completion: {
                    
                })
            }
            
            self.continueButton.isEnabled = true
            AmericaTVGoUtils.shared.hideHUD()
        }
    }
    
    @IBAction func handleSubscribeLater(_ sender: Any) {
        NotificationCenter.default.post(name: AmericaTVGoRegisterLaterNotification, object: nil, userInfo: ["sender": self])
    }
    
    // MARK: -
    
    @IBAction func showTerms(_ sender: Any) {
        let vc = AmericaTVWebViewViewController.init(nibName: nil, bundle: nil)
        vc.url = URL(string: "https://tvgo.americatv.com.pe/terminos-condiciones")
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func showPrivacy(_ sender: Any) {
        let vc = AmericaTVWebViewViewController.init(nibName: nil, bundle: nil)
        vc.url = URL(string: "https://tvgo.americatv.com.pe/politicas-de-privacidad")
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.present(navController, animated: true, completion: nil)
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
        if cell.containerView == self.selectedContainerView {
            return
        }
        
        if self.selectedContainerView != cell.containerView {
            self.selectedContainerView?.isSelected = false
        }
        self.selectedContainerView = cell.containerView
        self.selectedCell = cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let newWidth = collectionView.width
        let newHeight = (collectionView.height-8.0)/CGFloat(self.products.count)
        return CGSize(width: newWidth, height: newHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
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
    
    // MARK: -
    
    func requestDidFinish(_ request: SKRequest) {
        self.validateTransaction(self.currentTransaction!, product: self.currentProduct!, id: self.currentID!)
    }
    
    // MARK: -
    
    fileprivate func showSimpleAlert(title: String, message: String, completion: @escaping () -> Void) {
        let vc = AmericaTVGoAuthProvider.getTopMostViewController() ?? self
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { (_) -> Void in
            completion()
        })
        vc.present(alertController, animated: true, completion: nil)
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let vc = AmericaTVWebViewViewController.init(nibName: nil, bundle: nil)
        vc.url = url
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.present(navController, animated: true, completion: nil)
    }
}
