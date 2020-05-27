//
//  LoginPresenter.swift
//  GithubClient
//
//  Created by lieon on 2020/5/26.
//  Copyright © 2020 lieon. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

class LoginPresenter {
    weak var view: OAuthViewController?
    var interactor: LoginInteractor?
    
    
    func requestUserAuth(_ code: String) {
        interactor?.requestUserAuth(code)
    }
}
