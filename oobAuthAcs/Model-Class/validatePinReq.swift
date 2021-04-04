//
//  validatePinReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 06/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct validatePinReq : Codable {
    let tranId : String?
    let encPin : String?
    let custId : String?
    
    enum CodingKeys: String, CodingKey {
        case tranId = "tranId"
        case encPin = "encPin"
        case custId = "custId"
    }
}
