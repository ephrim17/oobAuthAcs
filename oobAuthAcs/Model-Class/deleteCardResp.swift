//
//  deleteCardResp.swift
//  oobAuthAcs
//
//  Created by LOB4 on 20/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation


struct deleteCardResp: Codable {
    var rc : String?
     var desc : String?
    
    enum CodingKeys: String, CodingKey {
        case rc = "rc"
        case desc = "desc"
    }
}
