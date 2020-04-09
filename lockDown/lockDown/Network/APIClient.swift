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
        
        return SendRequest(route: APIRouter.signUp(phoneNumber: phoneNumber), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },onFailure: {(errorMessage: String) -> Void in
            failureCallback?("errorMessage")
        })
    }
    
    static func signIn(phoneNumber:String, phoneOtp:String, phoneUdid:String) -> Future<UserData> {
        return performRequest(route: APIRouter.signIn(phoneNumber: phoneNumber, phoneOtp: phoneOtp, phoneUdid: phoneUdid))
    }
    
    static func sendTelimetry(deviceToken : String , iscomplaint : Int ,raison : String,onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                             onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
       
        return SendRequest(route: APIRouter.sendIsComplaint(deviceToken : deviceToken , iscomplaint: iscomplaint, raison: raison), onSuccess: { (responseObject: String) -> Void in
           successCallback?("successMessage")
       },
          onFailure: {(errorMessage: String) -> Void in
            print(errorMessage)
            failureCallback?("errorMessage")
       }
       )
   }
    
    
    static func sendLocationTelimetry(deviceid : String,latitude: String ,longitude : String , radius : String,onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                              onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.sendZoneLocations(deviceid: deviceid, latitude: latitude, longitude: longitude, radius: radius), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },
           onFailure: {(errorMessage: String) -> Void in
             print(errorMessage)
             failureCallback?("errorMessage")
        }
        )
    }
    
    
    static func sendFirebaseToken(deviceId : String , firebase_token : String,onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                              onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.sendFirebaseToken(deviceid: deviceId,firebase_token : firebase_token), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },
           onFailure: {(errorMessage: String) -> Void in
             print(errorMessage)
             failureCallback?("errorMessage")
        }
        )
    }
    
    static func sendSurveyTelimetry(deviceid : String, data:[String:Any],onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                              onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.sendSurvey(deviceid: deviceid, data: data), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },
           onFailure: {(errorMessage: String) -> Void in
             print(errorMessage)
             failureCallback?("errorMessage")
        }
        )
    }
    
    static func sendContactUSForm(data:[String:Any],onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                              onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.sendContactUsForm(data: data), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },
           onFailure: {(errorMessage: String) -> Void in
             print(errorMessage)
             failureCallback?("errorMessage")
        }
        )
    }
}
