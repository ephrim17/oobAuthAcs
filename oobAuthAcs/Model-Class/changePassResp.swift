//
//  changePassResp.swift
//  oobAuthAcs
//
//  Created by LOB4 on 17/12/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

//validateOldPassResp
struct validateOldPassResp : Codable {
    var rc : String?
    var desc : String?
    
    enum CodingKeys: String, CodingKey {
        case rc = "rc"
        case desc = "desc"
        
    }
}

//generateOtpByCustloginIdResp

struct generateOtpByCustloginIdResp : Codable {
    var rc : String?
    var desc : String?
     var reference_id : String?
    
    enum CodingKeys: String, CodingKey {
        case rc = "rc"
        case desc = "desc"
        case reference_id = "reference_id"
    }
}
