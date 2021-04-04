//
//  activeTranResp.swift
//  oobAuthAcs
//
//  Created by LOB4 on 28/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation


struct activeTranResp : Codable {
    let custId : String?
    let tranId : String?
    let url : String?
    let emailId : String?
    let secKey : String?
    let authType : String?
    let genPin : String?
    let genPinCount : Int?
    let rc : String?
    let desc : String?
    let txnAmount : String?
    let txnTime : String?
    let merchantName : String?
    
    enum CodingKeys: String, CodingKey {
        case custId = "custId"
        case tranId = "tranId"
        case url = "url"
        case emailId = "emailId"
        case secKey = "secKey"
        case authType = "authType"
        case genPin = "genPin"
        case genPinCount = "genPinCount"
        case rc = "rc"
        case desc = "desc"
        case txnAmount = "txnAmount"
        case txnTime = "txnTime"
        case merchantName = "merchantName"
    }
}
