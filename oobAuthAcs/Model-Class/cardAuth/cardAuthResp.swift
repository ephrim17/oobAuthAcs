//
//  cardAuthResp.swift
//  oobAuthAcs
//
//  Created by LOB4 on 18/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation


struct cardAuthResp : Codable {
    let rc : String?
    let desc : String?
    let reference_id : String?
    
    enum CodingKeys: String, CodingKey {
        case rc = "rc"
        case desc = "desc"
        case reference_id = "reference_id"
    }
}
