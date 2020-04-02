//
//  APIClient.swift
//  MotornaSwift
//
//  Created by Aymen HECHMI on 26/03/2020.
//  Copyright © 2020 IN:TIME Solutions. All rights reserved.
//

import Alamofire
import PromisedFuture
import ObjectMapper

class APIClient {
    
    // MARK: - Typealias
    fileprivate typealias JSONFormat = [String: Any]
    
    
    @discardableResult
    private static func performRequest<T: Mappable>(route: URLRequestConvertible) -> Future<T> {
        return Future(operation: { completion in
            
            Alamofire.request(route).responseJSON { (data) in
                
                // If we have a 401 on the login screen we can skip this logic since its a invalid login
                //                if data.response?.statusCode == 401 {
                //                        self.token(refresh: {
                //                            self.request(convertible: convertible, success: success, error: error, emptyResponse: emptyResponse, failure: failure)
                //                        })
                //                    } else {
                //                        (UIApplication.shared.delegate as? AppDelegate)?.userLoggedOut()
                //                    }
                //                    return
                //                }
                
                switch data.result {
                case .success:
                    if let value = data.result.value as? JSONFormat, let result = T(JSON: value) {
                        completion(.success(result))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        })
    }
    
    //    static func getLastLocation(email: String, password: String) -> Future<LastLocation> {
    //        return performRequest(route: APIRouter.login(email: email, password: password))
    //    }
    
    private static func SendRequest (route: URLRequestConvertible,onSuccess successCallback: ((String) -> Void)?, onFailure failureCallback: ((String) -> Void)?) {
        Alamofire.request(route).responseString { response in
            switch response.result {
            case .success(let value):
                successCallback?(value)
            case .failure(let error):
                failureCallback?(error.localizedDescription)
            }
        }
    }

    static func singUp(phoneNumber : String ,onSuccess successCallback: ((_ successMessage: String) -> Void)?, onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.signIn(phoneNumber: phoneNumber), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },onFailure: {(errorMessage: String) -> Void in
            failureCallback?("errorMessage")
        })
    }
}
