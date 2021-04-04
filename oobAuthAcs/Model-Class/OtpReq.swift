//
//  otpReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 01/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct otpReq: Codable {
    var emailAddr : String?
    var mobileNo : String?
    var isVerify: Int?
    
    enum CodingKeys: String, CodingKey {
        case emailAddr = "emailAddr"
        case mobileNo = "mobileNo"
        case isVerify = "isVerify"
    }
}
