//
//  otpVerfReq.swift
//  oobAuthAcs
//
//  Created by LOB4 on 01/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct otpVerfReq : Codable {
    var reference_id : String?
    var otp : String?
    
    enum CodingKeys: String, CodingKey {
        case reference_id = "reference_id"
        case otp = "otp"
    }
}
