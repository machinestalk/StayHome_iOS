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
                        if data.response?.statusCode == 200 {
                            if let value = data.result.value as? JSONFormat, let result = T(JSON: value) {
                                completion(.success(result))
                            }
                        }else{
                            let error = NSError(domain:"", code:data.response!.statusCode, userInfo:data.result.value as? [String : Any])
                                completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
            }
        })
    }
     static func performRequest<T: Mappable>(route: URLRequestConvertible) -> Future<[T]> {
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
                        if data.response?.statusCode == 200 {
                            if let value = data.result.value as? [JSONFormat] {
                                completion(.success(Mapper<T>().mapArray(JSONArray: value)))
                            }
                        }
                            
                        else{
                            let error = NSError(domain:"", code:data.response!.statusCode, userInfo:data.result.value as? [String : Any])
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            })
        }
   
    
    
    
    
    private static func SendRequest (route: URLRequestConvertible,onSuccess successCallback: ((String) -> Void)?, onFailure failureCallback: ((String) -> Void)?) {
        Alamofire.request(route).responseString { response in
            if response.response?.statusCode == 200 {
                switch response.result {
                case .success(let value):
                    successCallback?(value)
                case .failure(let error):
                    failureCallback?(error.localizedDescription)
                }
            }
            else {
                if response.response?.statusCode == 400 {
                    self.requestForGetNewAccessToken(route: route, onSuccess: successCallback, onFailure: failureCallback)
                }else{
                    //failureCallback?(response.result.error!.localizedDescription)
//                    let error = NSError(domain:"", code:response.response!.statusCode, userInfo:response.result as? [String : Any])
//                    failureCallback?(error.localizedDescription)
//                    //completion(.failure(error))
                }
            }
        }
    }
    
    private static func getData (route: URLRequestConvertible,onSuccess successCallback: ((String) -> Void)?, onFailure failureCallback: ((String) -> Void)?) {
        Alamofire.request(route).responseString { response in
            if response.response?.statusCode == 200 {
                switch response.result {
                case .success(let value):
                    successCallback?(value)
                case .failure(let error):
                    failureCallback?(error.localizedDescription)
                }
            }
            else {
                if response.response?.statusCode == 400 {
                    self.requestForGetNewAccessToken(route: route, onSuccess: successCallback, onFailure: failureCallback)
                }
                //failureCallback?(response.result.error!.localizedDescription)
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
    static func getRefreshToken(refreshToken : String) -> Future<UserData> {
        return performRequest(route: APIRouter.refrechToken(refreshToken: refreshToken))
    }
    
    
    static func sendTelimetry(deviceToken : String , iscomplaint : Int ,raison : String,zoneStatus: Int,onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                              onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.sendIsComplaint(deviceToken : deviceToken , iscomplaint: iscomplaint, raison: raison,zoneStatus:zoneStatus), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },
                           onFailure: {(errorMessage: String) -> Void in
                            print(errorMessage)
                            failureCallback?("errorMessage")
        }
        )
    }
    static func sendTelimetryWithoutZone(deviceToken : String , iscomplaint : Int ,raison : String,onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                              onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.sendIsComplaintWithoutZone(deviceToken : deviceToken , iscomplaint: iscomplaint, raison: raison), onSuccess: { (responseObject: String) -> Void in
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
    
    static func sendBLEScannedTelimetry(deviceToken : String, data:[String:Any],onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                                    onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.sendBLEScanned(deviceToken: deviceToken, data: data), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },
                           onFailure: {(errorMessage: String) -> Void in
                            print(errorMessage)
                            failureCallback?("errorMessage")
        })
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
    
    static func checkBracelet(data:[String:Any],onSuccess successCallback: ((_ successMessage: String) -> Void)?,
                              onFailure failureCallback: ((_ errorMessage: String) -> Void)?) {
        
        return SendRequest(route: APIRouter.addBracelet(params: data), onSuccess: { (responseObject: String) -> Void in
            successCallback?("successMessage")
        },
           onFailure: {(errorMessage: String) -> Void in
             print(errorMessage)
             failureCallback?("errorMessage")
        }
        )
    }
    
    
    static func getTipsHome(tenantId: String )-> Future<[HomeData]>{
        return performRequest(route: APIRouter.getTipsHome(tenantId: tenantId))
    }
    static func getCustomerData(customerId: String )-> Future<CustomerData>{
        return performRequest(route: APIRouter.getCustomerData(customerId: customerId))
    }
    static func requestForGetNewAccessToken(route: URLRequestConvertible,onSuccess successCallback: ((String) -> Void)?, onFailure failureCallback: ((String) -> Void)?) {
        
        if let refreshToken = UserDefaults.standard.string(forKey: "RefreshToken"){
            let userDataFuture = APIClient.getRefreshToken(refreshToken: refreshToken)
            userDataFuture.execute(onSuccess: { userData in
                UserDefaults.standard.set(userData.token, forKey:"Token")
                UserDefaults.standard.set(userData.refreshToken, forKey:"RefreshToken")
                
            }, onFailure: {error in
                print(error)
            })
        }
        let accessToken = UserDefaults.standard.string(forKey: "Token")
        
        do {
            var request = try route.asURLRequest()
            request.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
            request.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
            request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
            APIClient.SendRequest(route: request, onSuccess: { (responseObject: String) -> Void in
            },
               onFailure: {(errorMessage: String) -> Void in
                 print(errorMessage)
            })
            
        } catch {
            
        }
    }

    func createSimpleRequestString (
        _ url: String,
        method: HTTPMethod,
        headers: [String: String]?,
        parameters: [String: String]?,
        encoding: String,
        onSuccess successCallback: ((String) -> Void)?,
        onFailure failureCallback: ((String) -> Void)?) {
        Alamofire.request(url, method:method,parameters:parameters, headers: headers).validate()
            .responseString { response in
                switch response.result {
                case .success(let value):
                    successCallback?(value)
                case .failure(let error):
                    failureCallback?(error.localizedDescription)
                }
        }
    }


}
