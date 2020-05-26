//
//  ViewController.swift
//  GithubClient
//
//  Created by lieon on 2020/5/22.
//  Copyright © 2020 lieon. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import SnapKit
import RxCocoa

class ViewController: UIViewController {
    let bag = DisposeBag()
    
    fileprivate lazy var loginBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("GitHub Login", for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints {
            $0.center.equalTo(view.snp.center)
            $0.size.equalTo(CGSize(width: 80, height: 44))
        }
        view.backgroundColor = .white
        let provider = MoyaProvider<Reposities>()
        provider.rx.request(.trendingRepos(["since": "daily", "spoken_language_code": "db"]))
            .model([Repositry].self)
            .subscribe(onSuccess: { (response) in
                
            }, onError: nil)
            .disposed(by: bag)
        
        provider.rx.request(.laguage)
            .model([Language].self)
            .subscribe(onSuccess: { (response) in
                
            }, onError: nil)
            .disposed(by: bag)
        
        provider.rx.request(.trendingDeveloper(["since": "daily", "language": "swift"]))
            .model([TrendingDeveloper].self)
            .subscribe(onSuccess: { (response) in
                print(response)
            }, onError: nil)
            .disposed(by: bag)
        
        loginBtn.rx.tap
            .subscribe(onNext: { () in
//                let loginProvider = MoyaProvider<User>()
//                loginProvider.rx.request(.login(["client_id": "1f0f680ebb4d06f44b1a"]))
//                    .subscribe(onSuccess: { (response) in
//                        let data = response.data
//                    }, onError: nil)
//                    .disposed(by: self.bag)
                let webVC = OAuthViewController("https://github.com/login/oauth/authorize?client_id=1f0f680ebb4d06f44b1a")
                self.present(webVC, animated: true, completion: nil)
            })
        .disposed(by: bag)
    }
    
    
}

