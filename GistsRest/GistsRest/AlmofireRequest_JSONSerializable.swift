//
//  AlmofireRequest_JSONSerializable.swift
//  GistsRest
//
//  Created by 曹元乐 on 2017/3/18.
//  Copyright © 2017年 曹元乐. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Alamofire.DataRequest
{
    public func responseObject<T: ResponseJSONObjectSerializable>(completionHandler : @escaping (DataResponse<T>) -> Void) -> Self
    {
        let serializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
        
            guard let responseData = data else {
                let failureReason = "object can'be serialized because the input data is nil"
                let error = NSError(domain: failureReason, code: 1)
                return .failure(error)
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
            case .success(let value) :
                let json = SwiftyJSON.JSON(value)
                if let object = T(json : json) {
                    return .success(object)
                } else {
                    let failureReason = "Object can't be created from JSON"
                    let error = NSError(domain: failureReason, code: 2)
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(queue : nil, responseSerializer: serializer, completionHandler: completionHandler)
    }
    
    public func responseArray<T:ResponseJSONObjectSerializable>(completionHandler : @escaping (DataResponse<[T]>) -> Void) -> Self
    {
        let serializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil else {
                return .failure(error!)
            }
            
            guard let responseData = data else {
                let failureReason = "Array can't be serialized because the input data is nil"
                let error = NSError(domain: failureReason, code: 3)
                return .failure(error)
            }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options : .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
            case .success(let value) :
                let json = SwiftyJSON.JSON(value)
                var objects : [T] = []
                for(_, item) in json {
                    if let object = T(json : item) {
                        objects.append(object)
                    }
                }
                return .success(objects)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(queue : nil, responseSerializer: serializer, completionHandler : completionHandler)
        
    }
}
