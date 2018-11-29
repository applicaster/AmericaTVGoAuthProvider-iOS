//
//  AmericaTVGoAuthProvider.swift
//  ZappLoginPluginAmericaTVGO
//
//  Created by Roi Kedarya on 16/07/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import ApplicasterSDK
import ZappPlugins

class AmericaTVGoAuthProvider: NSObject, APAuthorizationClient {
    var delegate: APAuthorizationClientDelegate!
    
    let uniqueID = "americaTV"
    
    required init!(authorizationProvider authProvider: APAuthorizationProvider!, andParams params: [AnyHashable : Any]!) {
        super.init()
    }
    
    func startAuthorizationProcess() {
        let topMostViewController = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal()
        let americaTVGoLoginViewController = AmericaTVGoLoginViewController.init(nibName: "AmericaTVGoLoginViewController", bundle: Bundle(for: type(of: self)), andDelegate: delegate)
        topMostViewController?.present(americaTVGoLoginViewController, animated: true, completion: nil)
    }
    
    
}
