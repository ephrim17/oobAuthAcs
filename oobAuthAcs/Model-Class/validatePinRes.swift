//
//  validatePinRes.swift
//  oobAuthAcs
//
//  Created by LOB4 on 06/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct validatePinResp : Codable {
    let rc : String?
    let desc : String?
    let tranId : String?
    
    enum CodingKeys: String, CodingKey {
        case rc = "rc"
        case desc = "desc"
        case tranId = "tranId"
    }
}
