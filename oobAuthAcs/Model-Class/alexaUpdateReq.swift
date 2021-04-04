//
//  alexaUpdateReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 06/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct alexaUpdateReq : Codable {
    let emailID : String?
    let secPIN : String?
    let cust_id : String?
    
    enum CodingKeys: String, CodingKey {
        
        case emailID = "emailID"
        case secPIN = "secPIN"
        case cust_id = "cust_id"
    }
}
