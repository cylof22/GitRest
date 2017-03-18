//
//  Gist.swift
//  GistsRest
//
//  Created by 曹元乐 on 2017/3/18.
//  Copyright © 2017年 曹元乐. All rights reserved.
//

import Foundation
import SwiftyJSON

class Gist
{
    var m_id : String?
    var m_description : String?
    var m_ownerLogin : String?
    var m_ownerAvatorURL : String?
    var m_url : String?
    
    required init(json : JSON)
    {
        self.m_id = json["id"].string
        self.m_description = json["description"].string
        self.m_ownerLogin = json["owner"]["login"].string
        self.m_ownerAvatorURL = json["owner"]["avator_url"].string
        self.m_url = json["url"].string
    }
    
    required init()
    {
        
    }
}
