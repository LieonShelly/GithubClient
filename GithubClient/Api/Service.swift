//
//  Service.swift
//  GithubClient
//
//  Created by lieon on 2020/5/22.
//  Copyright © 2020 lieon. All rights reserved.
//

import Foundation
import Moya
import RxSwift

protocol AppTargetType: TargetType { }

extension AppTargetType {
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String : String]? {
        return [
            "Accept": "application/vnd.github.v3+json"
        ]
    }
}

enum Reposities: AppTargetType {
    case trendingRepos([String: Any])
    case trendingDeveloper([String: Any])
    case laguage
    
    var baseURL: URL {
        return URL(string: "https://ghapi.huchen.dev")!
    }
    
    var path: String {
        switch self {
        case .trendingRepos:
            return "/repositories"
        case .laguage:
            return "/languages"
        case .trendingDeveloper:
            return "/developers"
        }
        
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .trendingRepos(let param):
            let tast = Task.requestParameters(parameters: param, encoding: URLEncoding.default)
            return tast
        case .laguage:
            let tast = Task.requestParameters(parameters: [:], encoding: URLEncoding.default)
            return tast
        case .trendingDeveloper(let param):
            let tast = Task.requestParameters(parameters: param, encoding: URLEncoding.default)
            return tast
        }
    }
}

enum UserService: AppTargetType {
    case getAccessToken(String)
    case getAuthenticatedUser(String)// Get the authenticated user
    
    var baseURL: URL {
        switch self {
        case .getAccessToken:
            return URL(string: "https://github.com")!
        default:
            return URL(string: "https://api.github.com")!
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken:
            return "/login/oauth/access_token"
        case .getAuthenticatedUser:
            return "/user"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .getAccessToken:
            return .post
        case .getAuthenticatedUser:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getAccessToken(let code):
            let tast = Task.requestParameters(parameters: ["code": code,
                                                           "client_id": AppInfo.GitHub.clientId,
                                                           "client_secret": AppInfo.GitHub.clientSecret],
                                              encoding: URLEncoding.default)
            return tast
        case .getAuthenticatedUser(let accessToken):
            let tast = Task.requestParameters(parameters: ["access_token": accessToken],
                                              encoding: URLEncoding.default)
            return tast
        }
    }
    
    var headers: [String : String]? {
        return ["Accept": "application/json"]
    }
    
}
