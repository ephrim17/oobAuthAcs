//
//  changePassViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 17/12/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class changePassViewController: UIViewController, UITextFieldDelegate {
    
    
    //settingVariables
    var oldPass : String?
    var newPass :String?
    var ran1: String?
    var ran2: String?
    var sendOtpRefId: String?
    
    @IBOutlet weak var newPassTxtField: UITextField!
    @IBOutlet weak var oldPassTxtField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //addingDelegates
        newPassTxtField.delegate = self
        oldPassTxtField.delegate = self
        confirmTextField.delegate = self
        newPassTxtField.addBottomBorder()
        oldPassTxtField.addBottomBorder()
        confirmTextField.addBottomBorder()
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardRegViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        myButton.settings(button: submitBtn)
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        let validation = validationService()
        
        
        if oldPassTxtField.text == ""{
            Alert(Title: Common.Global.errorTitle, Message: "Old Password Field should not be empty")
        }
        
        guard let op = oldPassTxtField.text else {
            return Alert(Title: "Sorry", Message: "Please enter the old password") }
        
        guard validation.validatePass(password: op) else {
            return
                Alert(Title: Common.Global.errorTitle, Message: "Old Password should contain atleast 8 characters, 1 uppercase and 1 number")
        }
        oldPass = op
        
        if newPassTxtField.text == "" {
            Alert(Title: Common.Global.errorTitle, Message: "New Password Fields should not be empty")
        }
            
        if confirmTextField.text == "" {
            Alert(Title: Common.Global.errorTitle, Message: "Confirm Password Fields should not be empty")
        }
            
        else if newPassTxtField.text == confirmTextField.text{
            print("Pass Match")
            
            guard let ps =  newPassTxtField.text else {return}
            newPass = ps
            guard validation.validatePass(password: ps) else {
                return
                    Alert(Title: Common.Global.errorTitle, Message: "Password should contain atleast 8 characters, 1 uppercase and 1 number")
            }
            
            sendRequest(newPass: newPass!, oldPass: oldPass!)
        }
            
        else if newPassTxtField.text != confirmTextField.text{
            print("Pin Not Match")
            Alert(Title: Common.Global.errorTitle, Message: "Passwords does not Match")
        }
    }
    
    
    func sendRequest(newPass: String, oldPass: String){
        if CheckInternet.Connection(){
            print("internet Connected")
            
            //settingModelClass
            //gettingSecKeyfrom--localStoarge
            let userDefaults = UserDefaults.standard
            let secretKey = userDefaults.string(forKey: "secKey")
            let cid = userDefaults.string(forKey: "custId")
            
            let validateOldPassObj =  validateOldPass.init(cust_login_id: cid, oldPassword: oldPass)
            
            
            let sv = UIViewController.displaySpinner(onView: self.view)
            
            
            //Js-initialization
            let js = jsCore()
            print(js.initializeJS())
            
            let randomNumberFull = js.getRRNfromJS()
            
            let first19 = String("\(randomNumberFull)".prefix(19))
            ran1 = "\(first19)"
            
            let last8 = String("\(randomNumberFull)".suffix(8))
            ran2 = "\(last8)"
            
            var encString: String?;
            
            //Using jsonEncoder to convert it into JSON format
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(validateOldPassObj)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("Model.Class--------> \(String(describing: jsonString))")
            
            //encString_is_the_converted_JSON format for model class
            encString = jsonString
            
            let rsaHash = RSAHASH()
            
            //Getting Encrypted RRN
            let encRRN = rsaHash.RSAencc(value: ran1!, key: secretKey!)
            
            //Getting Encrypted Data
            let encData = rsaHash.RSAencc(value: encString!, key: secretKey!)
            
            //Getting Hashed Data
            let hasheddata = rsaHash.hmacSha(value: encString!, key: ran2!)
            
            let enccRequest = EncHashReq(encData: encData, rrn: encRRN, hashedData: hasheddata)
            print("Request Hit---------> \(enccRequest)")
            
            let http = httpService()
            http.call(ClassName: enccRequest, path: "validateoldpassword") { (mydata) in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(validateOldPassResp.self, from: mydata)
                    
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            self.generateOtpByCustloginId()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            guard let descResp = model.desc else { return}
                            self.Alert(Title: Common.Global.errorTitle, Message: "\(descResp)")
                        }
                    }
                }
                catch{
                    print("error")
                }
            }
        }
        
        else {
              self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    
    func generateOtpByCustloginId(){
        if CheckInternet.Connection(){
            print("internet Connected")
            
            //settingModelClass
            //gettingSecKeyfrom--localStoarge
            let userDefaults = UserDefaults.standard
            let secretKey = userDefaults.string(forKey: "secKey")
            let cid = userDefaults.string(forKey: "custId")
            
            let genCustLoginOtpObj =  generateOtpByCustloginIdReq.init(cust_login_id: cid)
            
            
            let sv = UIViewController.displaySpinner(onView: self.view)
            
            
            //Js-initialization
            let js = jsCore()
            print(js.initializeJS())
            
            let randomNumberFull = js.getRRNfromJS()
            
            let first19 = String("\(randomNumberFull)".prefix(19))
            ran1 = "\(first19)"
            
            let last8 = String("\(randomNumberFull)".suffix(8))
            ran2 = "\(last8)"
            
            var encString: String?;
            
            //Using jsonEncoder to convert it into JSON format
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(genCustLoginOtpObj)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("Model.Class--------> \(String(describing: jsonString))")
            
            //encString_is_the_converted_JSON format for model class
            encString = jsonString
            
            let rsaHash = RSAHASH()
            
            //Getting Encrypted RRN
            let encRRN = rsaHash.RSAencc(value: ran1!, key: secretKey!)
            
            //Getting Encrypted Data
            let encData = rsaHash.RSAencc(value: encString!, key: secretKey!)
            
            //Getting Hashed Data
            let hasheddata = rsaHash.hmacSha(value: encString!, key: ran2!)
            
            let enccRequest = EncHashReq(encData: encData, rrn: encRRN, hashedData: hasheddata)
            print("Request Hit---------> \(enccRequest)")
            
            let http = httpService()
            http.call(ClassName: enccRequest, path: "generateotpbycustloginid") { (mydata) in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(generateOtpByCustloginIdResp.self, from: mydata)
                    
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            self.sendOtpRefId = model.reference_id
                            self.performSegue(withIdentifier: "changePass", sender: self)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            guard let descResp = model.desc else { return}
                            self.Alert(Title: Common.Global.errorTitle, Message: "\(descResp)")
                        }
                    }
                }
                catch{
                    print("error")
                }
            }
        }
            
        else {
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "changePass") {
            let svc = segue.destination as! otpViewController
            svc.receiveotpRefId = sendOtpRefId
            svc.pageFlag = "changePass"
            svc.oldPass = oldPass
            svc.newPass = newPass
        }
    }
    
    
}//classClose


extension changePassViewController {
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
