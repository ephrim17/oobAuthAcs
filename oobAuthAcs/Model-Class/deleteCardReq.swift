//
//  deleteCardReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 20/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct deleteCardReq: Codable {
    var cust_id : String?
    var reference_id : String?
    
    enum CodingKeys: String, CodingKey {
        case cust_id = "cust_id"
        case reference_id = "reference_id"
    }
}
