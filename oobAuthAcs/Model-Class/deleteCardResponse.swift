//
//  deleteCardResponse.swift
//  oobAuthAcs
//
//  Created by LOB4 on 19/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct deleteCardRespOTP: Codable {
    var rc : String?
    var desc: String?
    var reference_id: String?
    
    enum CodingKeys: String, CodingKey {
        case rc = "rc"
        case desc = "desc"
        case reference_id = "reference_id"
    }
}
