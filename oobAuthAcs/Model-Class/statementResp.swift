//
//  statementResp.swift
//  oobAuthAcs
//
//  Created by LOB4 on 02/12/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

struct statementResp : Codable {
    let rc : String?
    let desc : String?
    let cust_login_id : String?
    let reportDetails : [ReportDetails]?
    
    enum CodingKeys: String, CodingKey {
        
        case rc = "rc"
        case desc = "desc"
        case cust_login_id = "cust_login_id"
        case reportDetails = "reportDetails"
    }
}


struct ReportDetails : Codable {
    let txnAmount : String?
    let merchantName : String?
    let status : String?
    let cust_id : String?
    let txn_time : String?
    
    enum CodingKeys: String, CodingKey {
        
        case txnAmount = "txnAmount"
        case merchantName = "merchantName"
        case status = "status"
        case cust_id = "cust_id"
        case txn_time = "txn_time"
    }
}
