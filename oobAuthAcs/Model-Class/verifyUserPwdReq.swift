//
//  verifyUserPwdReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 15/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct verifyUserPwdReq: Codable {
    var emailAddr : String?
    var mobileNo : String?
    var passWord: String?
    
    enum CodingKeys: String, CodingKey {
        case emailAddr = "emailAddr"
        case mobileNo = "mobileNo"
        case passWord = "passWord"
    }
}
