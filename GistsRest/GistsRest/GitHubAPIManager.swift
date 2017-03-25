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
    
    func getPublicGists(completionHandler : @escaping (Result<[Gist]>) -> Void) {
        Alamofire.request(GistRouter.GetPublic()).responseArray {
            (response : DataResponse<[Gist]>) in
            completionHandler(response.result)
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
}
