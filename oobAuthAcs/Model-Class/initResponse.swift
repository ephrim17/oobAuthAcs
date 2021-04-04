//
//  initResponse.swift
//  oobAuthAcs
//
//  Created by LOB4 on 01/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation


struct initResponse : Codable {
    let publicKey : String?
    let rc : String?
    let desc : String?
    let tranId : String?
    
    enum CodingKeys: String, CodingKey {
        
        case publicKey = "publicKey"
        case rc = "rc"
        case desc = "desc"
        case tranId = "tranId"
    }
}
