//
//  localStorage.swift
//  oobAuthAcs
//
//  Created by LOB4 on 21/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

public class Storage{
    
    
    //NotUsing
    class func myStorage(totpFlagVal : String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(totpFlagVal, forKey: "totpFlag")
        print("Storing the totpFlag as----\(String(describing: totpFlagVal))")
    }
    
    //To_Store_The_Public_key
    class func myPublicKey(Key : String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(Key, forKey: "secKey")
        print("Storing the public key as----\(String(describing: Key))")
    }
    
    //To_Store_The_LoginFlag
    class func loginFlag(flag : String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(flag, forKey: "loginFlag")
        print("Storing the loginFlag as----\(String(describing: flag))")
    }
    
    //To_Store_The_SoftToken_key
    class func totpKey(key : String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(key, forKey: "totpKey")
        print("Storing the totpKey as----\(String(describing: key))")
    }
    
    //To_Store_The_Customer_ID
    class func customerId(cid : String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(cid, forKey: "custId")
        print("Storing the customerId as----\(String(describing: cid))")
    }
}
