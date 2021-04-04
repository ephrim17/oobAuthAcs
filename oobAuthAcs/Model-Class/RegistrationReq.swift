//
//  Registration.swift
//  oobAuthAcs
//
//  Created by LOB4 on 17/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation


struct RegistrationReq : Codable {
    let appToken : String?
    let deviceID : String?
    let mobModel : String?
    let emailID : String?
    let secPIN : String?
    let cardNo : String?
    let authType : String?
    let reference_id : String?
    let cust_login_id : String?
    
    enum CodingKeys: String, CodingKey {
        case appToken = "appToken"
        case deviceID = "deviceID"
        case mobModel = "mobModel"
        case emailID = "emailID"
        case secPIN = "secPIN"
        case cardNo = "cardNo"
        case authType = "authType"
        case reference_id = "reference_id"
        case cust_login_id = "cust_login_id"
    }
}
