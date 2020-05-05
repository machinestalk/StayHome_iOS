//
//  APIRouter.swift
//  MotornaSwift
//
//  Created by Aymen HECHMI on 26/03/2020.
//  Copyright © 2020 IN:TIME Solutions. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    case signIn(phoneNumber:String, phoneOtp:String, phoneUdid:String)
    case signUp(phoneNumber: String)
    case sendIsComplaint(deviceToken : String,iscomplaint: Int,raison :String,zoneStatus: Int)
    case sendIsComplaintWithoutZone(deviceToken : String,iscomplaint: Int,raison :String)
    case sendZoneLocations(deviceid : String,latitude: String ,longitude : String , radius : String)
    case sendSurvey(deviceid : String, data:[String:Any])
    case sendFirebaseToken(deviceid : String, firebase_token : String)
    case sendContactUsForm(data:[String:Any])
    case refrechToken(refreshToken : String)
    case getTipsHome(tenantId : String)
    case getCustomerData(customerId : String)
    case sendBLEScanned(deviceToken : String, data:[String:Any])
    case addBracelet(params:[String:Any])
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .signUp,.signIn,.sendIsComplaint, .sendZoneLocations , .sendFirebaseToken, .sendSurvey, .refrechToken, .sendContactUsForm, .sendBLEScanned, .sendIsComplaintWithoutZone:
            return .post
        case .getTipsHome,.addBracelet,.getCustomerData:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        
        switch self {
        case .signIn:
            return "api/noauth/loginMobile"
        case .addBracelet(let params):
            let macAdress = params["macAddress"] as! String
            let deviceID = params["deviceId"] as! String
            let tenantID = params["tenantId"] as! String
            let customerID = params["customerId"] as! String
            
            return "api/customer-bracelet/device?macAddress=\(macAdress)&deviceId=\(deviceID)&tenantId=\(tenantID)&customerId=\(customerID)"
        case .signUp:
            return "api/noauth/signInCustomer"
        case .refrechToken:
            return "api/auth/token"
        case .sendIsComplaint(let parameters):
            return "api/v1/\(parameters.deviceToken)/telemetry"
        case .sendIsComplaintWithoutZone(let parameters):
            return "api/v1/\(parameters.deviceToken)/telemetry"
        case .sendBLEScanned(let parameters):
            return "api/v1/\(parameters.deviceToken)/telemetry"
        case .sendZoneLocations(let parameters):
            return "api/plugins/telemetry/CUSTOMER/\(parameters.deviceid)/timeseries/LATEST_TELEMETRY"
        case .sendFirebaseToken(let parameters) :
            return "api/plugins/telemetry/DEVICE/\(parameters.deviceid)/attributes/SERVER_SCOPE"
        case .sendSurvey(let parameters):
            return "api/plugins/telemetry/CUSTOMER/\(parameters.deviceid)/timeseries/LATEST_TELEMETRY"
        case .sendContactUsForm:
            return "api/noauth/contact-us"
        case .getTipsHome(let tenantId):
            return "api/plugins/telemetry/TENANT/\(tenantId)/values/attributes/SERVER_SCOPE"
        case .getCustomerData(let customerId):
            return "api/plugins/telemetry/CUSTOMER/\(customerId)/values/timeseries?limit=1"
        }
        
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .addBracelet:
            return nil
        case .signIn(let phoneNumber, let phoneOtp, let phoneUdid):
            return [LockDown.APIParameterKey.phoneNumber: phoneNumber, LockDown.APIParameterKey.phoneOtp: phoneOtp, LockDown.APIParameterKey.phoneUdid:phoneUdid]
        case .signUp(let phoneNumber):
            return [LockDown.APIParameterKey.phoneNumber: phoneNumber]
        case .refrechToken(let refreshToken):
            return [LockDown.APIParameterKey.refreshToken: refreshToken]
        case . sendIsComplaint(let parameters):
            return [LockDown.APIParameterKey.iscomplaint : parameters.iscomplaint , LockDown.APIParameterKey.raison : parameters.raison ,LockDown.APIParameterKey.zoneStatus : parameters.zoneStatus ]
        case . sendIsComplaintWithoutZone(let parameters):
            return [LockDown.APIParameterKey.iscomplaint : parameters.iscomplaint , LockDown.APIParameterKey.raison : parameters.raison ]
        case .sendZoneLocations(let parameters):
            return [LockDown.APIParameterKey.latitude : parameters.latitude , LockDown.APIParameterKey.longitude : parameters.longitude ,LockDown.APIParameterKey.radius : parameters.radius ]
        case .sendFirebaseToken(let parameters):
            return [LockDown.APIParameterKey.firebase_token : parameters.firebase_token]
        case .sendSurvey(let parameters):
            return parameters.data
        case .sendBLEScanned(let parameters):
            return parameters.data
        case .sendContactUsForm(let parameters):
            return parameters
        case .getTipsHome(let tenantId):
            return nil
        case .getCustomerData(let customerId):
            return nil
        }
    }
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try LockDown.ProductionServer.baseURL.asURL().appendingPathComponent(path)
        let urlString = "\(url)".removingPercentEncoding
        var urlRequest = URLRequest(url: URL(string: urlString!)!)
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        let accessToken = UserDefaults.standard.string(forKey: "Token")
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        urlRequest.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}
