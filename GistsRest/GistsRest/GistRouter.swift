//
//  GistRouter.swift
//  GistsRest
//
//  Created by 曹元乐 on 2017/3/12.
//  Copyright © 2017年 曹元乐. All rights reserved.
//

import Foundation
import Alamofire

enum GistRouter : URLRequestConvertible {
    static let baseURLString : String = "https://api.github.com"
    
    case GetPublic() // Get https://api/github.com/gists/public
    
    var URLRequest : URLRequest {
        
        var method : Alamofire.HTTPMethod {
            switch self {
            case .GetPublic:
                return Alamofire.HTTPMethod.get
            }
        }
        
        let result : (path : String, parameters : [String : AnyObject]?) = {
            switch self {
            case .GetPublic :
                return ("gists/public", nil)
            }
        }()
        
        var encodedRequest = try? Alamofire.JSONEncoding.default.encode(self, with : result.parameters)
        
        encodedRequest?.httpMethod = method.rawValue
        
        return encodedRequest!
    }
    
    func asURLRequest() throws -> URLRequest {
        
        let result : (path : String, parameters : [String : AnyObject]?) = {
            switch self {
            case .GetPublic :
                return ("gists/public", nil)
            }
        }()
        
        let baseURL = NSURL(string : GistRouter.baseURLString)
        let resultURL = baseURL?.appendingPathComponent(result.path)
        
        let urlRequest = NSMutableURLRequest(url: resultURL!)
        return urlRequest as URLRequest
    }
}
