//
//  AmericaTVWebViewViewController.swift
//  AmericaTVGoAuthProvider
//
//  Created by Jesus De Meyer on 1/31/19.
//  Copyright © 2019 applicaster. All rights reserved.
//

import UIKit
import WebKit

class AmericaTVWebViewViewController: UIViewController, WKNavigationDelegate{
    var url: URL?
    
    fileprivate var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone(_:)))
        
        let userContentController = WKUserContentController()
        let bundle = Bundle(for: self.classForCoder)
        
        if let scriptURL = bundle.url(forResource: "script", withExtension: "js") {
            if let scriptContent = try? String(contentsOf: scriptURL, encoding: .utf8) {
                let userScript = WKUserScript(source: scriptContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                userContentController.addUserScript(userScript)
            }
        }
        
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = userContentController
        
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(webView)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[webview]-0-|", options: [], metrics: nil, views: ["webview": webView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webview]-0-|", options: [], metrics: nil, views: ["webview": webView]))
        
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        loadURL()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    fileprivate func loadURL() {
        guard let theURL = url else {
            return
        }
        
        webView.load(URLRequest(url: theURL))
    }
    
    @objc
    func handleDone(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: -
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        AmericaTVGoUtils.shared.showHUD(self.view)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        AmericaTVGoUtils.shared.hideHUD()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        AmericaTVGoUtils.shared.hideHUD()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            decisionHandler(.cancel)
        default:
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // MARK: -

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            self.title = webView.title
        }
    }
}
