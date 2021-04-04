//
//  hash&EnccService.swift
//  oobAuthAcs
//
//  Created by LOB4 on 24/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation
import SwiftyRSA

public class RSAHASH {
    
    //HMAC_SHA256
    func hmacSha(value:String, key: String)->String{
        let hmac_md5 = value.hmac(algorithm: .sha256, key: key)
        return hmac_md5
    }
    
    
    //RSA-Encryption
    func RSAencc(value: String, key: String) -> String{
        
        var returnRSAencc : String!
    
        let base =  key
        let decodedData = Data(base64Encoded: base)!
        let decodedString = String(data: decodedData, encoding: .utf8)!
       // print("decodedString \(decodedString)")

        let keyString = decodedString.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "").replacingOccurrences(of: "\n-----END PUBLIC KEY-----", with: "")
        //print("key String \(keyString)")
        
        do {
            
            let publicKey = try PublicKey(base64Encoded: keyString)
           // print("public key \(publicKey)")
            let str =  value
            
            let clear = try? ClearMessage(string: "\(str)", using: .utf8)
            let encrypted = try? clear!.encrypted(with: publicKey, padding: .OAEP)
            let mydata = encrypted!.base64String
            
            returnRSAencc = mydata
        }
            
        catch {
            print(error.localizedDescription)
        }
        return returnRSAencc
    }
}
