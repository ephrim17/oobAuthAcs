//
//  signUpResp.swift
//  oobAuthAcs
//
//  Created by LOB4 on 13/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct signUpResp : Codable {
    let rc : String?
    let desc : String?
    let cust_login_id : String?
    
    enum CodingKeys: String, CodingKey {
        case rc = "rc"
        case desc = "desc"
        case cust_login_id = "cust_login_id"
    }
}
