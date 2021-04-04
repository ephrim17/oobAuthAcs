//
//  forgotPassViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 14/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class forgotViewController: UIViewController, UITextFieldDelegate, DataEnteredDelegate{
    
    func userDidEnterInformation(info: String) {
        pinCodeLabel.text = info
    }
    

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var emailMob: UITextField!
    @IBOutlet weak var pinCodeLabel: UILabel!
    
    
    //settingVariables
    var ran1: String?
    var ran2: String?
    
    //toReceiveMobCode
    var pinCode: String?
    
    //sendingVariables
    var sendOtpRefId: String?
    var sendEmailMob : String?
    var sendPwd : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myButton.settings(button: submitBtn)
        
        //addingDelegate
        emailMob.tintColor = .black
        emailMob.addBottomBorder()
        emailMob.delegate = self
        
        let tfSetting = textFieldSetting()
        //tfSetting.textFieldImageMailAndMob(txtfield: emailMob)
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(forgotViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //tap_gesture_forLabel
        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(loginViewController.tapFunction))
        pinCodeLabel.isUserInteractionEnabled = false
        pinCodeLabel.addGestureRecognizer(tapLabel)
        pinCodeLabel.alpha = 0.5
    }
    
    //pinCode_label_action
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        print("tap label")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "modal") as! modalViewController
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func loginHereAction(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func emailMobAction(_ textField: UITextField) {
        if let number = textField.text?.removeWhitespace() {
            if number.isEmpty {
                print("text field should not be empty")
                pinCodeLabel.isUserInteractionEnabled = false
                pinCodeLabel.alpha = 0.5
            }
                
            else if number.isInt && number.count > 5 {
                //button.alpha = 1
                //addButtonToTextField()
                pinCodeLabel.isUserInteractionEnabled = true
                pinCodeLabel.alpha = 1
                pinCodeLabel.text = "+91"
            }
                
            else if number.isInt && number.count == 6 {
                //button.alpha = 1
                //addButtonToTextField()
                pinCodeLabel.isUserInteractionEnabled = true
                pinCodeLabel.alpha = 1
                pinCodeLabel.text = "+91"
            }
                
            else {
                pinCodeLabel.isUserInteractionEnabled = false
                pinCodeLabel.alpha = 0.5
                //button.alpha = 0
            }
        }
        
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        
        if CheckInternet.Connection(){
            print("internet Connected")
            //For---Email
            if pinCodeLabel.alpha == 0.5 {
                
                guard let emt = emailMob.text?.count , emt > 0 else {
                    Alert(Title: Common.Global.errorTitle, Message: "Email-ID Should not be Empty 2")
                    return
                }
                
                guard let em = emailMob.text else {
                    Alert(Title: Common.Global.errorTitle, Message: "Email-ID Should not be Empty")
                    return
                }
                
                let validation = validationService()
                
                guard validation.validateEmail(enteredEmail: em)  else {
                    Alert(Title: Common.Global.errorTitle, Message: "Please enter the valid Email-ID")
                    return
                }
                
                sendEmailMob = em
                
                print("Send forgot Request for email--\(em)")
                sendForgotRequestMail(mail: em)
                
            }
                
                
                //For--Mob
            else {
                
                guard let emt = emailMob.text?.count , emt > 0 else {
                    Alert(Title: Common.Global.errorTitle, Message: "Mobile Number Should not be Empty 2")
                    return
                }
                
                guard let mn = emailMob.text else {
                    Alert(Title: Common.Global.errorTitle, Message: "Mobile Number Should not be Empty")
                    return
                }
                
                let withPinCode = pinCodeLabel.text! + mn
                
                let validation = validationService()
                
                guard validation.validateNumb(value: withPinCode)  else {
                    Alert(Title: Common.Global.errorTitle, Message: "Please enter the valid Mobile Number")
                    return
                }
                
                
                sendEmailMob = mn
                print("Send forgot Request for mob")
                sendForgotRequestMob(mob: mn)
                //print("Send Request for mobile --\(sendEmailMob)----\(sendPwd)")
            }
        }
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    
    func sendForgotRequestMail(mail: String) {
        //settingModelClass
        let otpReqObj =  otpReq.init(emailAddr: mail, mobileNo: nil, isVerify: 0)
        
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
        
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
        let jsonData = try! jsonEncoder.encode(otpReqObj)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print("Json.Encoder.Model.Class--------> \(String(describing: jsonString))")
        
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
        http.call(ClassName: enccRequest, path: "generateOTP") { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(otpResp.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        guard let otpRefId = model.reference_id else { return}
                        self.sendOtpRefId = otpRefId
                        self.performSegue(withIdentifier: "otpFpwd", sender: self)
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
    
    func sendForgotRequestMob(mob:String){
        //settingModelClass
        let otpReqObj =  otpReq.init(emailAddr: nil, mobileNo: mob, isVerify: 0)
        
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
        
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
        let jsonData = try! jsonEncoder.encode(otpReqObj)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print("Json.Encoder.Model.Class--------> \(String(describing: jsonString))")
        
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
        http.call(ClassName: enccRequest, path: "generateOTP") { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(otpResp.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        guard let otpRefId = model.reference_id else { return}
                        self.sendOtpRefId = otpRefId
                        self.performSegue(withIdentifier: "otpFpwd", sender: self)
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
    
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "otpFpwd") {

            let svc = segue.destination as! otpViewController
            svc.receiveotpRefId = sendOtpRefId
            svc.pageFlag = "fpwd"
            svc.loginObj = sendEmailMob
        }
    }
    

}//ClassClose


extension forgotViewController {
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
