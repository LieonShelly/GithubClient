//
//  LoginInteractor.swift
//  GithubClient
//
//  Created by lieon on 2020/5/26.
//  Copyright © 2020 lieon. All rights reserved.
//

import Foundation

class LoginInteractor {
    weak var presenter: LoginPresenter?
    
    deinit {
        print("LoginInteractor - deinit")
    }
}
