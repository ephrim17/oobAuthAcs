//
//  loginReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 14/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation


struct loginReq : Codable {
    let emailAddr : String?
    var passWord : String?
    var reference_id: String?
    let mobileNo: String?
    let appToken : String?
    
    enum CodingKeys: String, CodingKey {
        
        case emailAddr = "emailAddr"
        case passWord = "passWord"
        case reference_id = "reference_id"
        case mobileNo = "mobileNo"
        case appToken = "appToken"
    }
}
