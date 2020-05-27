//
//  LoginInteractor.swift
//  GithubClient
//
//  Created by lieon on 2020/5/26.
//  Copyright © 2020 lieon. All rights reserved.
//

import RxCocoa
import RxSwift
import Moya

class LoginInteractor {
    weak var presenter: LoginPresenter?
    let bag = DisposeBag()
    
    func requestUserAuth(_ code: String) {
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
    }
    deinit {
        print("LoginInteractor - deinit")
    }
}
