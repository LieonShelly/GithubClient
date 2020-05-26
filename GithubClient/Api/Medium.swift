//
//  Medium.swift
//  GithubClient
//
//  Created by lieon on 2020/5/22.
//  Copyright © 2020 lieon. All rights reserved.
//

import Foundation
import Moya
import RxSwift

enum ErrorCode: Int {
    case none
}

class AppError: Error {
    var message: String
    var code: ErrorCode
    
    init(message: String, code: ErrorCode) {
        self.message = message
        self.code = code
    }
}

extension AppError: LocalizedError {
    var localizedDescription: String {
        return message
    }
}


extension PrimitiveSequence where Trait == SingleTrait, Element == Moya.Response {
    func model<T: Codable>(_ type: T.Type) -> Single<T> {
        return flatMap{
            return Single.just(try $0.model(type))
        }
    }
}

extension Response {
    
    func model<T: Codable>(_ type: T.Type) throws -> T {
        print("✈ -------------------------------------------- ✈")
        print("[URL]\t:", self.request?.urlRequest?.url ?? "")
        if let paramData = request?.urlRequest?.httpBody {
            do{
                let param = try JSONSerialization.jsonObject(with: paramData, options: JSONSerialization.ReadingOptions.allowFragments)// as? [String: Any]
                print("[PARAM]\t:",param)
            }catch let e {
                print("[PARAM]\t:", String(data: paramData, encoding: String.Encoding.utf8) ?? "[ERROR]\t:\(e.localizedDescription)")
            }
        }
        if let header = request?.allHTTPHeaderFields {
            print("[HEADER]\t:",header)
        }
        if statusCode == 200  {
            let decoder = JSONDecoder()
            guard let ret = try? decoder.decode(type, from: data) else {
                throw AppError(message: "加载失败，请检查网络链接", code: ErrorCode(rawValue: statusCode) ?? .none)
            }
            return ret
        } else {
            throw AppError(message: "message", code: ErrorCode(rawValue: statusCode) ?? .none)
        }
    }
}


extension ObservableType where Element == Response {
    
    func model<T: Codable>(_ type: T.Type) -> Observable<T> {
        return flatMap {
            return Observable.just(try $0.model(type))
        }
    }
}


func logger(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    print("✈ -------------------------------------------- ✈")
    print(items, separator: separator, terminator: terminator)
}
