//
//  activeTranReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 28/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct activeTranReq: Codable {
    var cust_login_id : String?
    
    enum CodingKeys: String, CodingKey {
        case cust_login_id = "cust_login_id"
    }
}
