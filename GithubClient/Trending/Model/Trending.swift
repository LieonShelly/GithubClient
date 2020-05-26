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

class User: Author {
    /// 一个伪单例
    static var shared: User = User()
    var access_token: String?
    var token_type: String?
    var scope: String?
    var userId: Int?
    var type: String?
    var site_admin: Bool = false
    var login: String?
    var company: String?
    var blog: String?
    var location: String?
    var email: String?
    var hireable: String?
    var bio: String?
    var public_repos: Int = 0
    var public_gists: Int = 0
    var followers: Int = 0
    var following: Int = 0
    var created_at: String?
    var updated_at: String?
    
    private let queue = DispatchQueue(label: "userData")
    private var userDataPath: String {
        let document = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .allDomainsMask, false).first
        let path = "/User"
        let userDocument = document! + path
        var isdir: ObjCBool = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: userDocument, isDirectory: &isdir) {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: userDocument), withIntermediateDirectories: true, attributes: nil)
        }
        return userDocument
    }
    
    enum CodingKeys: String, CodingKey {
        case userName = "name"
        case avatar = "avatar_url"
        case userId = "id"
        case access_token
        case token_type
        case scope
        case type
        case site_admin
        case login
        case company
        case blog
        case location
        case email
        case hireable
        case bio
        case public_repos
        case public_gists
        case followers
        case following
        case created_at
        case updated_at
    }
    
    required internal init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: CodingKeys.userName)
        avatar = try container.decode(String.self, forKey: CodingKeys.avatar)
        userId = try container.decode(Int.self, forKey: CodingKeys.userId)
        if let access_token = try? container.decode(String.self, forKey: CodingKeys.access_token) {
            self.access_token = access_token
        }
        if let token_type = try? container.decode(String.self, forKey: CodingKeys.token_type) {
            self.token_type = token_type
        }
        if let scope = try? container.decode(String.self, forKey: CodingKeys.scope) {
            self.scope = scope
        }
        if let type = try? container.decode(String.self, forKey: CodingKeys.type) {
            self.type = type
        }
        if let site_admin = try? container.decode(Bool.self, forKey: CodingKeys.site_admin) {
            self.site_admin = site_admin
        }
        login = try? container.decode(String.self, forKey: CodingKeys.login)
        company = try? container.decode(String.self, forKey: CodingKeys.company)
        blog = try? container.decode(String.self, forKey: CodingKeys.blog)
        location = try? container.decode(String.self, forKey: CodingKeys.location)
        email = try? container.decode(String.self, forKey: CodingKeys.email)
        hireable = try? container.decode(String.self, forKey: CodingKeys.hireable)
        bio = try container.decode(String.self, forKey: CodingKeys.bio)
        if let public_repos = try? container.decode(Int.self, forKey: CodingKeys.public_repos) {
            self.public_repos = public_repos
        }
        if let public_gists = try? container.decode(Int.self, forKey: CodingKeys.public_gists) {
            self.public_gists = public_gists
        }
        if let followers = try? container.decode(Int.self, forKey: CodingKeys.followers) {
            self.followers = followers
        }
        if let following = try? container.decode(Int.self, forKey: CodingKeys.following) {
            self.following = following
        }
        created_at = try? container.decode(String.self, forKey: CodingKeys.created_at)
        updated_at = try? container.decode(String.self, forKey: CodingKeys.updated_at)
    }
    
    func read() {
        let userDataPath = userDatPath()
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: userDataPath)) else {
            return
        }
        let decoder = JSONDecoder()
        guard let user =  try? decoder.decode(User.self, from: jsonData) else {
            return
        }
        User.shared = user
    }
    
    func write(_ complete: ((Bool) -> Void)?) {
        let jsonEncoder = JSONEncoder()
        guard let json = try? jsonEncoder.encode(User.shared) else {
            return
        }
        let userPath = userDataPath
        queue.async(group: nil, qos: .default, flags: .barrier) {
            do {
                try json.write(to: URL(fileURLWithPath: userPath))
                complete?(true)
            } catch {
                complete?(false)
            }
        }
    }
    
    
    func update(_ json: [String: Any]) {
        guard let oldJsonData = try? JSONEncoder().encode(User.shared) else {
            return
        }
        guard var oldJSON = try? JSONSerialization.jsonObject(with: oldJsonData, options: .allowFragments) as? [String: Any] else {
            return
        }
        logger("update before JSON: \n \(oldJSON)")
        for inputKey in json.keys {
            oldJSON[inputKey] = json[inputKey]
        }
        logger("update after JSON: \n \(oldJSON)")
        guard let newJSONData = try? JSONSerialization.data(withJSONObject: oldJSON, options: .fragmentsAllowed) else {
            return
        }
        do {
            let newUser = try JSONDecoder().decode(User.self, from: newJSONData)
            User.shared = newUser
            logger("new user Data: \n  \(User.shared)")
            User.shared.write(nil)
        } catch {
            logger("eror:\n\(error.localizedDescription)")
        }
        //        guard let newUser = try? JSONDecoder().decode(User.self, from: newJSONData) else {
        //            return
        //        }
        //        User.shared = newUser
        //        logger("new user Data: \n  \(User.shared)")
        //        User.shared.write(nil)
    }
    
    private func userDatPath() -> String {
        let userPath = userDataPath + "/" + "user.data"
        return userPath
    }
    
}


class Language: Codable {
    var urlParam: String?
    var name: String?
}
