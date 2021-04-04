//
//  forgotPassResp.swift
//  oobAuthAcs
//
//  Created by LOB4 on 15/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct forgotPassResp : Codable {
    let rc : String?
    let desc : String?
    
    enum CodingKeys: String, CodingKey {
        case rc = "rc"
        case desc = "desc"
    }
}
