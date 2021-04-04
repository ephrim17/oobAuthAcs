//
//  checkFace&Touch.swift
//  oobAuthAcs
//
//  Created by LOB4 on 31/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation
import LocalAuthentication

//TouchId_&&_FaceID_is_available_??
class LocalAuth: NSObject {
    
    public static let shared = LocalAuth()
    
    private override init() {}
    
    var laContext = LAContext()
    
    func canAuthenticate() -> Bool {
        var error: NSError?
        let hasTouchId = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return hasTouchId
    }
    
    func hasTouchId() -> Bool {
        if #available(iOS 11.0, *) {
            if canAuthenticate() && laContext.biometryType == .touchID {
                return true
            }
        } else {
            // Fallback on earlier versions
        }
        return false
    }
    
    func hasFaceId() -> Bool {
        if #available(iOS 11.0, *) {
            if canAuthenticate() && laContext.biometryType == .faceID {
                return true
            }
        } else {
            // Fallback on earlier versions
        }
        return false
    }
    
}
