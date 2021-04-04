//
//  deleteCardRequest.swift
//  oobAuthAcs
//
//  Created by LOB4 on 19/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation


struct deleteCardReqOTP: Codable {
    var cust_id : String?
    
    enum CodingKeys: String, CodingKey {
        case cust_id = "cust_id"
    }
}
