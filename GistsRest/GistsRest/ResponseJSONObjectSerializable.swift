//
//  ResponseJSONObjectSerializable.swift
//  GistsRest
//
//  Created by 曹元乐 on 2017/3/18.
//  Copyright © 2017年 曹元乐. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol ResponseJSONObjectSerializable
{
    init?(json : SwiftJSON)
}
