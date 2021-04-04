//
//  ResetPassViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 15/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class ResetPassViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var confirmPassTextfield: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    //ReceiveVariables
    var emailMobNum: String?
    var refId: String?
    
    //settingVariables
    var passWd: String?
    var ran1: String?
    var ran2: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myButton.settings(button: submitBtn)
        
        print("Received refId RPVC--\(String(describing: refId))")
        
        //addingDelegates
        passTextField.delegate = self
        confirmPassTextfield.delegate = self
        passTextField.addBottomBorder()
        confirmPassTextfield.addBottomBorder()
        
        let tfSetting = textFieldSetting()
        tfSetting.textFieldImageKey(txtfield: passTextField)
        tfSetting.textFieldImageKey(txtfield: confirmPassTextfield)
        
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardRegViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func submitaction(_ sender: Any) {
        if CheckInternet.Connection(){
            print("internet Connected")
            if passTextField.text == ""  || confirmPassTextfield.text == "" {
                Alert(Title: Common.Global.errorTitle, Message: "Password Fields should not be empty")
            }
                
            else if passTextField.text == confirmPassTextfield.text{
                print("Pin Match")
                
                guard let ps =  passTextField.text else {return}
                passWd = ps
                
                let validation =  validationService()
                
                guard validation.validatePass(password: ps) else {
                    Alert(Title: Common.Global.errorTitle, Message: "Password should contain atleast 8 characters, 1 uppercase and 1 number")
                    return
                }
                
                guard let mn = emailMobNum else { return }
                sendRequest(emailMob:mn, pwd: ps)
            }
                
            else if passTextField.text != confirmPassTextfield.text{
                print("Pin Not Match")
                Alert(Title: Common.Global.errorTitle, Message: "Passwords does not Match")
            }
        }
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    
    func sendRequest(emailMob:String, pwd: String){
        var num:String?
        var email:String?
        
        //Sending Request as mob if loginCrd is mob
        if emailMob.isInt {
            //settingModelClass
            num = emailMob
            let cardReqObj = forgotPassReq.init(emailAddr: nil, mobileNo: num, passWord: pwd, reference_id: refId)
            
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
            let jsonData = try! jsonEncoder.encode(cardReqObj)
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
            http.call(ClassName: enccRequest, path: "forgotpassword") { (mydata) in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(forgotPassResp.self, from: mydata)
                    
                    print("Response from completion handler")
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            print("Navigate to login page")
                             guard let msg = model.desc else { return}
                            
                            let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                                print("Navigate to Home")
                                self.performSegue(withIdentifier: "login", sender: self)
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
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
            
            
            //Sending Request as Email if loginCrd is email
        else {
            email = emailMob
            let cardReqObj = forgotPassReq.init(emailAddr: email, mobileNo: nil, passWord: pwd, reference_id: refId)
            
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
            let jsonData = try! jsonEncoder.encode(cardReqObj)
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
            http.call(ClassName: enccRequest, path: "forgotpassword") { (mydata) in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(forgotPassResp.self, from: mydata)
                    
                    print("Response from completion handler")
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            print("Navigate to login page")
                            guard let msg = model.desc else { return}
                            
                            let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                                print("Navigate to Home")
                                self.performSegue(withIdentifier: "login", sender: self)
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
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
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "login") {
            _ = segue.destination as! loginViewController
        }
    }
    
    
}//classClose


extension ResetPassViewController {
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
