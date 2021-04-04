//
//  RegistrationResp.swift
//  oobAuthAcs
//
//  Created by LOB4 on 21/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct RegistrationRes : Codable {
    
    let rc : String?
    let desc : String?
    let secKey : String?
    let cust_login_id : String?
    
    enum CodingKeys: String, CodingKey {
        
        case rc = "rc"
        case desc = "desc"
        case secKey = "secKey"
        case cust_login_id = "cust_login_id"
    }
}
