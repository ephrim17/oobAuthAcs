//
//  otpViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 19/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import Lottie

class otpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var subBtn: UIButton!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var otpAnimationView: AnimationView!
    
    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //SettingVariables
    var sendOtpRefId: String?
    var sendCardNum:String?
    var sendMnum:String?
    var sendEmail:String?
    //var otp: String?
    var ran1: String?
    var ran2: String?
    
    //forChangePass_alone
    var oldPass : String?
    var newPass :String?
    
    //Receiving_Variables
    var receiveotpRefId: String?
    var receivecardNum: String?
    var receiveMobNum:String?
    var receiveEmail:String?
    var receivePwd: String?
    var pageFlag: String?
    var loginObj: String?
    var receiveCustId: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("received variables ----\(String(describing: receiveotpRefId)) -----\(String(describing: loginObj)) ---\(String(describing: receivePwd))")
        setup()
        sendMnum = receiveMobNum
        sendEmail = receiveEmail
        sendCardNum =  receivecardNum
        
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func verifyAction(_ sender: Any) {
        
        
        if CheckInternet.Connection(){
            print("internet Connected")
            //otp = otpTextField.text
            
            guard let otemp = otpTextField.text , otemp.count == 6  else {
                Alert(Title: Common.Global.errorTitle, Message: "OTP length should not be less than six")
                return
            }
            
            //settingModelClass
            let cardReqObj = otpVerfReq.init(reference_id: receiveotpRefId, otp: otemp)
            
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
            http.call(ClassName: enccRequest, path: "validateOTP") { (mydata) in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(otpVerfResp.self, from: mydata)
                    
                    print("Response from completion handler")
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            self.sendOtpRefId = model.reference_id
                            self.routePage(refId: model.reference_id!)
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
            
        else{
            self.Alert(Title: "Alert", Message: Common.Global.internetAlertMsge)
        }
        
  
    }
    
    
    //Routing--based--on--Page flag
    func routePage(refId: String){
        if pageFlag == "login" {
            sendLoginOtpRequest(loginCrd: loginObj!, pwd: receivePwd!, RefId: refId)
        }
            
        else if pageFlag == "fpwd" {
            print("Route to forgot password page")
            self.performSegue(withIdentifier: "resetPwd", sender: self)
        }
            
        else if pageFlag == "addCard" {
            print("calling sendCardRegRequest ")
            sendCardRegRequest(cardNum: receivecardNum!, RefId: refId)
        }
            
        else if pageFlag == "deleteCard" {
            print("calling deleteCard Request ")
           sendDeleteCardRequest(custID: receiveCustId!, RefId: refId)
        }
        
        else if pageFlag == "changePass" {
            print("calling change Password Request ")
            changePassRequest(RefId: refId)
        }
            
        else {
            self.performSegue(withIdentifier: "setpwd", sender: self)
        }
    }
    
    
    func  sendCardRegRequest(cardNum: String, RefId: String) {
        
        if CheckInternet.Connection(){
            print("internet Connected")
            guard let deviceInformation = appDelegate.deviceID else {
                return
            }
            
            guard  let deviceModel = appDelegate.model else{
                return
            }
            
            guard let appTokenID = appDelegate.FireBaseTokenID else{
                return
            }
            
            let js = jsCore()
            print(js.initializeJS())
            
            let randomNumberFull = js.getRRNfromJS()
            
            let first19 = String("\(randomNumberFull)".prefix(19))
            ran1 = "\(first19)"
            //print("19digits-----\(first19)")
            
            let last8 = String("\(randomNumberFull)".suffix(8))
            ran2 = "\(last8)"
            //print("8digits-----\(last8)")
            
            var encString: String?;
            
            //gettingSecKeyfrom--localStoarge
            let userDefaults = UserDefaults.standard
            let secretKey = userDefaults.string(forKey: "secKey")
            let cid = userDefaults.string(forKey: "custId")
            
            let sv = UIViewController.displaySpinner(onView: self.view)
            
            let regReq = RegistrationReq.init(appToken: appTokenID, deviceID: deviceInformation, mobModel: deviceModel, emailID: nil, secPIN: nil, cardNo: cardNum, authType: "1,3,4", reference_id: RefId, cust_login_id: cid)
            
            print("Model class request-----\(regReq)")
            
            //Using jsonEncoder to convert it into JSON format
            let jsonEncoder = JSONEncoder()
            let jsonData = try! jsonEncoder.encode(regReq)
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
            
            let Request = EncHashReq(encData: encData, rrn: encRRN, hashedData: hasheddata)
            print("Request Hit---------> \(Request)")
            
            let http = httpService()
            
            http.call(ClassName: Request, path: "customerregistration") { (mydata) in
                DispatchQueue.main.async {
                    UIViewController.removeSpinner(spinner: sv)
                }
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(RegistrationRes.self, from: mydata)
                    print("Response from completion handler")
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            print("navigate to dashBoard")
                            guard let msg = model.desc else {return}
                            let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                                print("Navigate to Home")
                                self.performSegue(withIdentifier: "lhome", sender: self)
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
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    
    func sendLoginOtpRequest(loginCrd: String, pwd: String, RefId: String) {
        
        var num:String?
        var email:String?
        
        if CheckInternet.Connection(){
            print("internet Connected")
            //Sending Request as mob if loginCrd is mob
            if loginCrd.isInt {
                //settingModelClass
                num = loginCrd
                
                guard let aptkn = appDelegate.FireBaseTokenID else { return }
                
                
                let cardReqObj = loginReq.init(emailAddr: nil, passWord: pwd, reference_id: RefId, mobileNo: num, appToken: aptkn)
                
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
                print("sendLoginOtpRequest--------> \(String(describing: jsonString))")
                
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
                http.call(ClassName: enccRequest, path: "login") { (mydata) in
                    do {
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(loginResp.self, from: mydata)
                        
                        print("Response from completion handler")
                        print(model)//Decode JSON Response Data
                        
                        if (model.rc == "00"){
                            DispatchQueue.main.async {
                                UIViewController.removeSpinner(spinner: sv)
                                guard let custId = model.cust_login_id else { return }
                                Storage.customerId(cid: custId)
                                Storage.loginFlag(flag: "true")
                                self.performSegue(withIdentifier: "lhome", sender: self)
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
                email = loginCrd
                //settingModelClass
                
                guard let aptkn = appDelegate.FireBaseTokenID else { return }
                
                
                let cardReqObj = loginReq.init(emailAddr: email, passWord: pwd, reference_id: RefId, mobileNo: nil, appToken: aptkn)
                
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
                http.call(ClassName: enccRequest, path: "login") { (mydata) in
                    do {
                        let decoder = JSONDecoder()
                        let model = try decoder.decode(loginResp.self, from: mydata)
                        
                        print("Response from completion handler")
                        print(model)//Decode JSON Response Data
                        
                        if (model.rc == "00"){
                            DispatchQueue.main.async {
                                UIViewController.removeSpinner(spinner: sv)
                                guard let custId = model.cust_login_id else { return }
                                Storage.customerId(cid: custId)
                                self.performSegue(withIdentifier: "lhome", sender: self)
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
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
       
    }
    
    
    func sendDeleteCardRequest(custID: String, RefId: String) {
        //settingModelClass
        let delReqObj =  deleteCardReq.init(cust_id: custID, reference_id: RefId)
        
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
        let jsonData = try! jsonEncoder.encode(delReqObj)
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
        http.call(ClassName: enccRequest, path: "deactivatecustcard") { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(otpResp.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        print("Navigate to dash board again")
                        guard let msg = model.desc else {return}
                        let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                            print("Navigate to Home")
                            self.performSegue(withIdentifier: "lhome", sender: self)
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
    
    
    func changePassRequest(RefId : String){
        
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
           let cid = userDefaults.string(forKey: "custId")
        
        //settingModelClass
        let changePassObj = changePassReq.init(cust_login_id: cid, oldPassword: oldPass!, passWord: newPass!, reference_id: RefId)
        
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
        let jsonData = try! jsonEncoder.encode(changePassObj)
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
        http.call(ClassName: enccRequest, path: "changepassword") { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(otpResp.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        print("Navigate to dash board again")
                        guard let msg = model.desc else {return}
                        let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                            print("Navigate to Home")
                            self.performSegue(withIdentifier: "lhome", sender: self)
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
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "setpwd") {
            let svc = segue.destination as! setPassViewController
            svc.refId = sendOtpRefId!
            svc.email = sendEmail
            svc.mobNum = sendMnum
        }
            
        else if (segue.identifier == "lhome") {
            print("Navigating to home")
            let nav = segue.destination as! UINavigationController
            _ = nav.topViewController as! homeViewController
        }
            
            //resetPwd
        else if (segue.identifier == "resetPwd") {
            let svc = segue.destination as! ResetPassViewController
            svc.emailMobNum = loginObj
            svc.refId = sendOtpRefId
        }
        
    }
    
}//ClassClose


extension otpViewController{
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Limit_textField_characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = textField.text!.utf8CString.count + string.utf8CString.count - range.length
        
        //print(textField.tag)
        
        if textField.tag == otpTextField.tag{
            return newLength <= 8
        }
            
        else{
            return newLength <= 8
        }
    }
    
    //adding_Image_on_textField
    func textFieldImage(){
        otpTextField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "key")
        imageView.image = image
        otpTextField.leftView = imageView
    }
    
    
    //Setup---views
    func setup() {
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //DisplayLottie
        DispatchQueue.main.async {
            myButton.settings(button: self.subBtn)
            self.loadLottie()
        }
        
        //textFieldDelegate
        otpTextField.tintColor = .black
        self.otpTextField.delegate = self
        self.otpTextField.addBottomBorder()
        
        //let tfSetting = textFieldSetting()
        //tfSetting.textFieldImageKey(txtfield: otpTextField)
    }
    
//    //loadLottie
//    func loadLottie(){
//        let animationView = AnimationView(name: "OTPAnim")
//        animationView.frame = CGRect(x: view.bounds.midX, y: view.bounds.midY + 100, width: self.view.frame.width, height: 100)
//        animationView.contentMode = .scaleAspectFit
//        animationView.loopMode = .loop
//        animationView.play()
//        view.addSubview(animationView)
//    }
    
    func loadLottie(){
        let animationView = AnimationView()
        animationView.animation = Animation.named("OTPAnim")
        animationView.frame.size = otpAnimationView.frame.size
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        otpAnimationView.addSubview(animationView)
        animationView.play()
    }
}
