//
//  enccHash.swift
//  oobAuthAcs
//
//  Created by LOB4 on 24/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct EncHashReq : Codable {
    let encData : String?
    let rrn : String?
    let hashedData : String?
    
    enum CodingKeys: String, CodingKey {
        
        case encData = "encData"
        case rrn = "rrn"
        case hashedData = "hashedData"
    }
}
