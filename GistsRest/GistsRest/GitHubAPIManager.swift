//
//  GitHubAPIManager.swift
//  GistsRest
//
//  Created by 曹元乐 on 2017/3/12.
//  Copyright © 2017年 曹元乐. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

class GitHubAPIManager
{
    static let sharedInstance = GitHubAPIManager();
    static let ErrorDomain = "com.error.GitHubAPIManager"
    
    var OAuthToken : String? = nil
    var OAuthTokenCompletionHandler : ((NSError?) -> Void)? = nil
    
    let clientId = "098a02c4e7928561c4d2"
    let clientSecret = "e37cf85af0af39c9fdfa2240944f8313b62dfd11"
    
    func processOAuthStep1Response(url : URL) {
        let components = NSURLComponents(url : url, resolvingAgainstBaseURL: false)
        var code:String?
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if (queryItem.name.lowercased() == "code") {
                    code = queryItem.value
                    break
                }
            }
        }
        
        if let receivedCode = code {
           swapAuthcodeForToken(receivedCode: receivedCode)
            if(hasOAuthToken()) {
                getStarredGistWithOAuth2()
            }
        }
        else {
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "loadingOAuthToken")
            if let completionHandler = self.OAuthTokenCompletionHandler {
                let error = NSError(domain: GitHubAPIManager.ErrorDomain, code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Could not obtain an auth code", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                completionHandler(error)
            }
        }
    }
    
    func swapAuthcodeForToken(receivedCode : String)
    {
        let getTokenPath:String = "https://github.com/login/oauth/access_token"
        let tokenParams = ["client_id": clientId, "client_secret": clientSecret, "code": receivedCode]
        let jsonHeader = ["Accept": "application/json"]
        Alamofire.request(getTokenPath, method: .post, parameters: tokenParams, headers: jsonHeader)
            .responseString { response in
                if let error = response.result.error {
                    let defaults = UserDefaults.standard
                    defaults.set(false, forKey: "loadingOAuthToken")
                    return
                }
                
                print(response.result.value)
                // TODO: handle response to extract OAuth token
                if let receivedResults = response.result.value, let jsonData = receivedResults.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    let jsonResults = JSON(data: jsonData)
                    for (key, value) in jsonResults {
                        switch key {
                        case "access_token":
                            self.OAuthToken = value.string
                        case "scope":
                            // TODO: verify scope
                            print("SET SCOPE")
                        case "token_type":
                            // TODO: verify is bearer
                            print("CHECK IF BEARER")
                        default:
                            print("got more than I expected from the OAuth token exchange")
                            print(key)
                        }
                    }
                }
            }
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "loadingOAuthToken")
        
        if let completionHandler = self.OAuthTokenCompletionHandler {
            if(hasOAuthToken()) {
                completionHandler(nil)
            } else {
                let noOAuthError = NSError(domain: GitHubAPIManager.ErrorDomain, code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Could not obtain an OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                //completionHandler(noOAuthError)
            }
        }
    }
    
    func hasOAuthToken() -> Bool {
        return OAuthToken != nil && !(OAuthToken!.isEmpty)
    }
    
    func urlToStartOAuth2Login() -> NSURL? {
        let authPath = "https://github.com/login/oauth/authorize" + "?client_id=\(clientId)&scope=gist&state=TEST_STATE"
        guard let authURL: NSURL = NSURL(string : authPath) else {
            return nil
        }
        
        return authURL
    }
    
    func printPublicGists() -> Void {
        Alamofire.request(GistRouter.GetPublic()).responseJSON {
            response in
            if let receivedString = response.result.value {
                print(receivedString)
            }
        }
    }
    
    func getPublicGists(pageToLoad : String?, completionHandler : @escaping (Result<[Gist]>, String?) -> Void) {
        if let urlString = pageToLoad {
            self.getGists(urlRequest: GistRouter.GetPath(urlString), completionHandler: completionHandler)
        } else
        {
            self.getGists(urlRequest: GistRouter.GetPublic(), completionHandler: completionHandler)
        }
    }
    
    func getStarredGists(pageToLoad : String?, completionHandler : @escaping (Result<[Gist]>, String?) -> Void) {
        if let urlString = pageToLoad {
            self.getGists(urlRequest: GistRouter.GetPath(urlString), completionHandler: completionHandler)
        } else {
            self.getGists(urlRequest: GistRouter.GetStarred(), completionHandler: completionHandler)
        }
    }
    
    func getStarredGistWithOAuth2() -> Void
    {
        Alamofire.request(GistRouter.GetStarred()).responseJSON {
            response in
            guard response.result.error == nil else {
                print(response.result.error!)
                return
            }
            
            if let receivedString = response.result.value {
                print(receivedString)
            }
        }
    }
    
    func getStarredGistWithBasicAuth() -> Void
    {
        Alamofire.request(GistRouter.GetStarred()).responseJSON {
            response in
            if let receivedString = response.result.value {
                print(receivedString)
            }
        }
    }
    
    func imageFromURLString(imageURLString : String, completionHandler :
        @escaping (UIImage?, NSError?) -> Void)
    {
        Alamofire.request(imageURLString, method : .get).response {
            (response : Alamofire.DefaultDataResponse) in
            //(request, response, data, error) in
            if response.data == nil {
                completionHandler(nil, nil)
                return
            }
            
            let image = UIImage(data : response.data!)
            completionHandler(image, nil)
        }
    }
    
    private func getGists(urlRequest : URLRequestConvertible, completionHandler :
                @escaping (Result<[Gist]>, String?) -> Void)
    {
        Alamofire.request(urlRequest)
        .validate()
            .responseArray {
                (response : DataResponse<[Gist]>) in
                guard response.result.error == nil,
                    let gists = response.result.value else {
                        print(response.result.error!)
                        completionHandler(response.result, nil)
                        return
                }
                
                let next = self.getNextPagesFromHeaders(response: response.response)
                completionHandler(.success(gists), next)
        }
    }
    
    private func getNextPagesFromHeaders(response : HTTPURLResponse?) -> String?
    {
        if let linkHeader = response?.allHeaderFields["link"] as? String {
            let components = linkHeader.characters.split{ $0 == ","}.map{String($0)}
            for item in components {
                let rangeOfNext = item.range(of : "rel=\"next\"", options:[])
                if rangeOfNext != nil {
                    let rangeOfPaddedURL = item.range(of : "<(.*)>", options : .regularExpression)
                    if let range = rangeOfPaddedURL {
                        let nextURL = item.substring(with: range)
                        let startIndex = nextURL.index(nextURL.startIndex, offsetBy: 1)
                        let endIndex = nextURL.index(nextURL.endIndex, offsetBy: -2)
                        let urlRange = startIndex ..< endIndex
                        return nextURL.substring(with : urlRange)
                    }
                }
            }
        }
        
        return nil
    }
}
