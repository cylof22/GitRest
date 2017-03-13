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
}
