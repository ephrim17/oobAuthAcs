//
//  changePassReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 17/12/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

//validatingOldPassword
struct validateOldPass : Codable {
    var cust_login_id : String?
    var oldPassword : String?
    
    enum CodingKeys: String, CodingKey {
        case cust_login_id = "cust_login_id"
        case oldPassword = "oldPassword"
        
    }
}


//generateOtpByCustloginIdReq
struct generateOtpByCustloginIdReq :Codable {
    var cust_login_id : String?
    
    enum CodingKeys: String, CodingKey {
        case cust_login_id = "cust_login_id"
    }
}


//changePassReq
struct changePassReq : Codable {
    var cust_login_id : String?
    var oldPassword : String?
    var passWord : String?
    var reference_id : String?
    
    enum CodingKeys: String, CodingKey {
        case cust_login_id = "cust_login_id"
        case oldPassword = "oldPassword"
        case passWord = "passWord"
        case reference_id = "reference_id"
        
    }
}
