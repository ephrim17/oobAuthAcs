//
//  signUpReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 13/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct signUpReq : Codable {
    let emailAddr : String?
    let mobileNo : String?
    let passWord : String?
    let reference_id : String?
    let appToken: String?
    
    enum CodingKeys: String, CodingKey {
        
        case emailAddr = "emailAddr"
        case mobileNo = "mobileNo"
        case passWord = "passWord"
        case reference_id = "reference_id"
        case appToken = "appToken"
    }
}
