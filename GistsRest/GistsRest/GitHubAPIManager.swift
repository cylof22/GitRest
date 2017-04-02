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
