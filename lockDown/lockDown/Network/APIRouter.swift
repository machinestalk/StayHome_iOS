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
    case sendIsComplaint(deviceToken : String,iscomplaint: Int)

    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .signUp,.signIn,.sendIsComplaint:
            return .post
        }
    }
    
    // MARK: - Path
    private var path: String {
        
        switch self {
        case .signIn:
            return "api/noauth/loginMobile"
        case .signUp:
            return "api/noauth/signInCustomer"
        case . sendIsComplaint(let parameters):
            return "api/v1/\(parameters.deviceToken)/telemetry"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .signIn(let phoneNumber, let phoneOtp, let phoneUdid):
            return [LockDown.APIParameterKey.phoneNumber: phoneNumber, LockDown.APIParameterKey.phoneOtp: phoneOtp, LockDown.APIParameterKey.phoneUdid:phoneUdid]
            case .signUp(let phoneNumber):
            return [LockDown.APIParameterKey.phoneNumber: phoneNumber]
         case . sendIsComplaint(let parameters):
                return [LockDown.APIParameterKey.iscomplaint : parameters.iscomplaint]
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try LockDown.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        let accessToken = UserDefaults.standard.string(forKey: "access_token")
        
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
