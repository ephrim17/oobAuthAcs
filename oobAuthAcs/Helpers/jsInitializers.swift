//
//  jsInitializers.swift
//  oobAuthAcs
//
//  Created by LOB4 on 24/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation
import JavaScriptCore



public class jsCore{
     var jsContext: JSContext!
    
    //Initializing_myJS.js_file
    func initializeJS()->String{
        self.jsContext = JSContext()
        // Specify the path to the jssource.js file.
        if let jsSourcePath = Bundle.main.path(forResource: "myJS", ofType: "js") {
            do {
                // Load its contents to a String variable.
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                
                // Add the Javascript code that currently exists in the jsSourceContents to the Javascript Runtime through the jsContext object.
                self.jsContext.evaluateScript(jsSourceContents)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        return "calling initializeJS"
    }
    
    //Calling_JS_func--"toggle"
    func getRRNfromJS()->String{
        
        var randomNum: String!
        
        if let variableRandomNumber = self.jsContext.objectForKeyedSubscript("toggleRRN") {
            
            randomNum = "\(variableRandomNumber)"
            print("Random Number Full---\(variableRandomNumber)")
            
            //let first19 = String("\(variableRandomNumber)".prefix(19))
            //print("19digits-----\(first19)")
            
            //let last8 = String("\(variableRandomNumber)".suffix(8))
            //print("8digits-----\(last8)")
            
        }
        
        return randomNum
    }
    
    //Calling_JS_func--for"cardBrandName"
    func cardBrandName(cc: String)->String{
        
        var cardBrandName: String!
        
//        if let cName = self.jsContext.objectForKeyedSubscript("validateCard") {
//
//            cardBrandName = "\(cName)"
//            print("Random Number Full---\(cName)")
//        }
        
        if let variableHelloWorld = self.jsContext.objectForKeyedSubscript("validateCard") {
            let result = variableHelloWorld.call(withArguments: ["\(cc)"])
            cardBrandName = result!.toString()
            print(result!.toString())
        }
        
        return cardBrandName
    }
    
    
    
    //Calling_JS_func--for"ValidateEmailMob"
    func ValidateEmailMob(EM: String)->String{
        
        var ValidateEmailMobText: String!
        
        if let variableHelloWorld = self.jsContext.objectForKeyedSubscript("ValidateEmailMob") {
            let result = variableHelloWorld.call(withArguments: ["\(EM)"])
            ValidateEmailMobText = result!.toString()
            print(result!.toString())
        }
        return ValidateEmailMobText
    }
}


