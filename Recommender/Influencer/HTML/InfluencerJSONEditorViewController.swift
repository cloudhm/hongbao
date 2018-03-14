//
//  InfluencerJSONEditorViewController.swift
//  Recommender
//
//  Created by huangmin on 13/03/2018.
//  Copyright © 2018 huangmin. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
/**
 * controller cannot be released to lead memory leak
 * https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
 */
class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(_ delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController,
                                             didReceive: message)
    }
    deinit {
        print("deinit LeakAvoider")
    }
}
class InfluencerJSONEditorViewController: UIViewController {
    class MessageHandler {
        static let getValue = "getValue"
    }
    var webView : WKWebView!
    var progressView : UIProgressView!
    let keyPath_EstimatedProgress = "estimatedProgress"
    var influencer : Influencer?
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(LeakAvoider(self), name: MessageHandler.getValue)
        configuration.userContentController = userContentController
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.scrollView.bouncesZoom = false
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.bottom.right.top.equalTo(0)
        }
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.backgroundColor = UIColor.red
        progressView.alpha = 0
        view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(1)
        }
        webView.addObserver(self, forKeyPath: keyPath_EstimatedProgress, options: .new, context: nil)
        guard let path = Bundle.main.path(forResource: "test2", ofType: "html") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            guard let htmlString = String(data: data, encoding: .utf8) else { return }
            webView.loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: path))
        } catch {
            
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == keyPath_EstimatedProgress {
            progressView.alpha = 1.0
            progressView.setProgress((Float)(webView.estimatedProgress), animated: true)
            if self.webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish : Bool) in
                    self.progressView.setProgress(0, animated: false)
                })
            }
        }
    }
    deinit{
        webView?.stopLoading()
        webView?.removeObserver(self, forKeyPath: keyPath_EstimatedProgress)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: MessageHandler.getValue)
    }
}
extension InfluencerJSONEditorViewController : WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        if message.name == MessageHandler.getValue {
            guard let influencerJSON = message.body as? [String:Any] else {
                return
            }
            // post influencer
        }
    }
}
extension InfluencerJSONEditorViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let influencer = influencer else {return}
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(influencer)
            guard let jsonStr = String(data: data, encoding: String.Encoding.utf8) else {return}
            webView.evaluateJavaScript(jsonStr) {[weak self] (response, error) in
                
            }
        }catch{
            
        }

        decisionHandler(.allow)
    }
}


