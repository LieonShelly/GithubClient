//
//  LoginRouter.swift
//  GithubClient
//
//  Created by lieon on 2020/5/26.
//  Copyright © 2020 lieon. All rights reserved.
//

import UIKit

/// 串联VIPER的其他模块，contains navigation logic for describing which screens are shown in which order.
/// 用于创建一个VIPER模块，决定当前屏幕显示的页面是哪个模块, push, present 到其他VC
class LoginRouter {
    class func createLoginModule(_ url: String) -> UIViewController {
        let presenter = LoginPresenter()
        let interactor = LoginInteractor()
        let view = OAuthViewController(url)
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter
        return view
    }
}
