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
    
    case GetStarred()
    
    case GetPath(String)
    
    func asURLRequest() throws -> URLRequest {
        
        var method : Alamofire.HTTPMethod {
            switch self {
            case .GetPublic:
                return Alamofire.HTTPMethod.get
            case .GetStarred:
                return Alamofire.HTTPMethod.get
            case .GetPath:
                return Alamofire.HTTPMethod.get
            }
        }
        
        let result : (path : String, parameters : [String : AnyObject]?) = {
            switch self {
            case .GetPublic :
                return ("gists/public", nil)
            case .GetStarred:
                return ("gists/starred", nil)
            case .GetPath(let path):
                let url = NSURL(string: path)
                let relativePath = url!.relativePath!
                return (relativePath, nil)
            }
        }()
        
        let baseURL = NSURL(string : GistRouter.baseURLString)
        let resultURL = baseURL?.appendingPathComponent(result.path)
        
        let urlRequest = NSMutableURLRequest(url: resultURL!)
        
        if let token = GitHubAPIManager.sharedInstance.OAuthToken {
            urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest as URLRequest
    }
}
