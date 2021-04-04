//
//  cardAuthReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 18/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct cardAuthReq : Codable {
    let cardNo : String?
    var cust_login_id : String?
    var isUpdate : Bool?
    
    enum CodingKeys: String, CodingKey {
        case cardNo = "cardNo"
        case cust_login_id = "cust_login_id"
        case isUpdate = "isUpdate"
    }
}
