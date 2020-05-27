//
//  Trending.swift
//  GithubClient
//
//  Created by lieon on 2020/5/22.
//  Copyright © 2020 lieon. All rights reserved.
//

import Foundation


class Repositry: Codable {
    var author: String?
    var name: String?
    var avatar: String?
    var url: String?
    var description: String?
    var language: String?
    var stars: Int = 0
    var forks: Int  = 0
    var currentPeriodStars: Int = 0
    var builtBy: [Author]?
}

class TrendingDeveloper: Author {
    var repo: Repositry?
    var sponsorUrl: String?
}

class Author: Model, Codable {
    var username: String?
    var href: String?
    var avatar: String?
    
}

class Model: CustomStringConvertible {
    required init() { }
    
    var description: String {
        var str = "\n"
        let properties = Mirror(reflecting: self).children
        for child in properties {
            if let name = child.label {
                str += name + ": \(child.value)\n"
            }
        }
        return str
    }
}


class Language: Codable {
    var urlParam: String?
    var name: String?
}
