//
//  OAuthViewController.swift
//  GithubClient
//
//  Created by lieon on 2020/5/23.
//  Copyright © 2020 lieon. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Moya
import RxCocoa
import RxSwift


class OAuthViewController: UIViewController {
    fileprivate lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    var urlStr: String?
    let bag = DisposeBag()
    var presenter: LoginPresenter?
    
    convenience init(_ url: String) {
        self.init()
        self.urlStr = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
        if let urlStr = urlStr {
            let request = URLRequest(url: URL(string: urlStr)!)
            webView.load(request)
        }
    }
}

extension OAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let redirectURL = AppInfo.GitHub.redirectURL
        let request = navigationAction.request
        
        if let url = request.url,
            url.absoluteString.starts(with: redirectURL),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,  let queryParam = queryItems.filter({ $0.name == "code"}).first {
            if let code = queryParam.value {
                let provider = MoyaProvider<UserService>()
                provider.rx
                    .request(.getAccessToken(code))
                    .mapJSON()
                    .flatMap({ (response) -> Single<Response> in
                        guard let response = response as? [String: Any] else {
                            return  Single<Response>.never()
                        }
                        guard let accesstoken = response["access_token"] as? String,
                            let scope = response["scope"] as? String,
                            let tokenType = response["token_type"] as? String else {
                                return  Single<Response>.never()
                        }
                        User.shared.access_token = accesstoken
                        User.shared.scope = scope
                        User.shared.token_type = tokenType
                        return provider.rx.request(.getAuthenticatedUser(accesstoken))
                    })
                    .mapJSON()
                    .subscribe(onSuccess: { (response) in
                        if let response = response as? [String: Any] {
                            User.shared.update(response)
                        }
                    })
                    .disposed(by: bag)
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
        
    }
}
