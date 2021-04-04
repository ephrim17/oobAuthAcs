//
//  authSuccessReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 05/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct authenticationReq : Codable {
    let tranId : String?
    let custId : String?
    let authType : String?
    let rc : String?
    let desc : String?
    
    enum CodingKeys: String, CodingKey {
        
        case tranId = "tranId"
        case custId = "custId"
        case authType = "authType"
        case rc = "rc"
        case desc = "desc"
    }
}
