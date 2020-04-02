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
    
    case login(phoneNumber:String, phoneOtp:String, phoneUdid:String)
    case signIn(phoneNumber: String)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login,.signIn:
            return .post
        }
    }
    
    // MARK: - Path
    private var path: String {
        
        switch self {
        case .login:
            return "api/noauth/loginMobile"
        case .signIn:
            return "api/noauth/signInCustomer"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .login(let phoneNumber, let phoneOtp, let phoneUdid):
            return [LockDown.APIParameterKey.phoneNumber: phoneNumber, LockDown.APIParameterKey.phoneOtp: phoneOtp, LockDown.APIParameterKey.phoneOtp:phoneUdid]
            case .signIn(let phoneNumber):
            return [LockDown.APIParameterKey.phoneNumber: phoneNumber]
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
