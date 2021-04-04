//
//  loginViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 11/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class loginViewController: UIViewController, UITextFieldDelegate, DataEnteredDelegate {
    
    func userDidEnterInformation(info: String) {
        print("Received \(info)")
        //guard let em = "\(info)" else {return}
        pinCodeLabel.text = info
    }
    
    @IBOutlet weak var pinCodeLabel: UILabel!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    //@IBOutlet weak var emailMobTextField: FPNTextField!
    @IBOutlet weak var emailMobTextField: UITextField!
    let button = UIButton(type: .custom)
    
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
        
        
        if CheckInternet.Connection(){
            print("internet Connected")
            loadRequest()
        }
            
        else{
             self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    
      
        
        //tap_gesture_forLabel
        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(loginViewController.tapFunction))
        pinCodeLabel.isUserInteractionEnabled = false
        pinCodeLabel.addGestureRecognizer(tapLabel)
        pinCodeLabel.alpha = 0.5
        
        
        myButton.settings(button: loginBtn)
        
        //AddingDelegates
        emailMobTextField.tintColor = .black
        passwdTextField.tintColor = .black
        emailMobTextField.delegate = self
        passwdTextField.delegate = self
        //textFieldImagePin()
        //textFieldImageMail()
        emailMobTextField.addBottomBorder()
        passwdTextField.addBottomBorder()
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    
    @IBAction func loginAction(_ sender: Any) {
        
        
        if CheckInternet.Connection(){
            print("internet Connected")
            //For---Email
            if pinCodeLabel.alpha == 0.5 {
                
                //print("result without pin-----\(String(describing: sendEmailMob)) ------\(pinCodeLabel.alpha)")
                
                
                guard let emt = emailMobTextField.text?.count , emt > 0 else {
                    Alert(Title: Common.Global.errorTitle, Message: "Email-ID Should not be Empty")
                    return
                }
                
                guard let em = emailMobTextField.text else {
                    Alert(Title: Common.Global.errorTitle, Message: "Email-ID Should not be Empty")
                    return
                }
                
                let validation = validationService()
                
                guard validation.validateEmail(enteredEmail: em)  else {
                    Alert(Title: Common.Global.errorTitle, Message: "Please enter the valid Email-ID")
                    return
                }
                
                guard let tempPwd = passwdTextField.text?.count , tempPwd > 0 else {
                    Alert(Title: Common.Global.errorTitle, Message: "Password Should not be Empty")
                    return
                }
                
                guard let pwd = passwdTextField.text else{
                    Alert(Title: Common.Global.errorTitle, Message: "Password Should not be Empty")
                    return
                }
                
                guard (passwdTextField.text?.count)! > 7 else {
                    Alert(Title: Common.Global.errorTitle, Message: "Password length should not be less than eight")
                    return
                }
                
                guard validation.validatePass(password: pwd) else {
                    Alert(Title: Common.Global.errorTitle, Message: "Password should contain atleast 8 characters, 1 uppercase and 1 number")
                    return
                }
                
                sendEmailMob = em
                sendPwd = pwd
                
                print("Send Request for email")
                //sendLoginRequestMail(mail: sendEmailMob)
                
                verifyUser(loginCr: sendEmailMob!, pw: sendPwd!)
                
            }
                
                
                //For--Mob
            else {
                
                //print("result-----\(pinCodeLabel.text)----\(emailMobTextField.text)")
                
                guard let emt = emailMobTextField.text?.count , emt > 0 else {
                    Alert(Title: Common.Global.errorTitle, Message: "Mobile Number Should not be Empty")
                    return
                }
                
                guard let mn = emailMobTextField.text else {
                    Alert(Title: Common.Global.errorTitle, Message: "Mobile Number Should not be Empty")
                    return
                }
                
                let withPinCode = pinCodeLabel.text! + mn
                
                let validation = validationService()
                
                
                guard validation.validateNumb(value: withPinCode)  else {
                    Alert(Title: Common.Global.errorTitle, Message: "Please enter the valid Mobile Number")
                    return
                }
                
                guard let tempPwd = passwdTextField.text?.count , tempPwd > 0 else {
                    Alert(Title: Common.Global.errorTitle, Message: "Password Should not be Empty")
                    return
                }
                
                guard let pwd = passwdTextField.text else{
                    Alert(Title: Common.Global.errorTitle, Message: "Password Should not be Empty")
                    return
                }
                
                guard (passwdTextField.text?.count)! > 7 else {
                    Alert(Title: Common.Global.errorTitle, Message: "Password length should not be less than eight")
                    return
                }
                
                guard validate(password: pwd) else {
                    Alert(Title: Common.Global.errorTitle, Message: "Password should contain atleast 8 characters, 1 uppercase and 1 number")
                    return
                }
                
                sendEmailMob = withPinCode.replacingOccurrences(of: "+", with: "", options: NSString.CompareOptions.literal, range: nil)
                sendPwd = pwd
                
                //print("Send Request for mobile --\(sendEmailMob)----\(String(describing: sendPwd))")
                //sendLoginRequestMob(mob: sendEmailMob)
                
                verifyUser(loginCr: sendEmailMob!, pw: sendPwd!)
            }
            
            
        }
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
    }
}

    
    @IBAction func emailMobAction(_ textField: UITextField) {
        // print("TextFieldAction ---called")
        if let number = textField.text?.removeWhitespace() {
            
            if number.isEmpty {
                print("text field should not be empty")
                pinCodeLabel.isUserInteractionEnabled = false
                pinCodeLabel.alpha = 0.5
            }
                
            else if number.isInt && number.count > 5 {
                pinCodeLabel.isUserInteractionEnabled = true
                pinCodeLabel.alpha = 1
                pinCodeLabel.text = "+91"
            }
                
            else if number.isInt && number.count == 6 {
                pinCodeLabel.isUserInteractionEnabled = true
                pinCodeLabel.alpha = 1
                pinCodeLabel.text = "+91"
            }
                
            else {
                pinCodeLabel.isUserInteractionEnabled = false
                pinCodeLabel.alpha = 0.5
            }
        }
        
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        print("Navigate to forgot password page")
    }
    
    
    func verifyUser(loginCr: String, pw: String) {
         print("loginCr----\(loginCr)")
        if loginCr.isInt {
            
            print("loginCr----\(loginCr)")
            //settingModelClass
            let verifyUserObj = verifyUserPwdReq.init(emailAddr: nil, mobileNo: loginCr, passWord: pw)
            
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
            let jsonData = try! jsonEncoder.encode(verifyUserObj)
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
            http.call(ClassName: enccRequest, path: "verifypassword") { (mydata) in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(otpResp.self, from: mydata)
                    
                    print("Response from completion handler")
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            print("verify user success")
                            self.sendLoginRequestMob(mob: self.sendEmailMob)
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
            //settingModelClass
            let verifyUserObj = verifyUserPwdReq.init(emailAddr: loginCr, mobileNo: nil, passWord: pw)
            
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
            let jsonData = try! jsonEncoder.encode(verifyUserObj)
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
            http.call(ClassName: enccRequest, path: "verifypassword") { (mydata) in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(otpResp.self, from: mydata)
                    
                    print("Response from completion handler")
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            print("verify user success")
                            self.sendLoginRequestMail(mail: self.sendEmailMob)
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
    
    
    func sendLoginRequestMail(mail: String?){
        //settingModelClass
        let otpReqObj =  otpReq.init(emailAddr: mail, mobileNo: "", isVerify: 1)
        
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
                        self.performSegue(withIdentifier: "otpLogin", sender: self)
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
    
    func sendLoginRequestMob(mob: String?){
        //settingModelClass
        let otpReqObj =  otpReq.init(emailAddr: "", mobileNo: mob, isVerify: 1)
        
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
                        self.performSegue(withIdentifier: "otpLogin", sender: self)
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
        
        if (segue.identifier == "otpLogin") {
            //let nav = segue.destination as! UINavigationController
            //_ = nav.topViewController as! homeViewController
            //svc.toPassSearchKeyword = searchKeyword;
            
            //let svc = segue.destination as! setPassViewController
            //svc.email = EmailtoSent
            //svc.refId = sendOtpRefId
            //svc.mobNum = mobNumbtoSent
            
            let svc = segue.destination as! otpViewController
            svc.receiveotpRefId = sendOtpRefId
            svc.loginObj = sendEmailMob
            svc.receivePwd = sendPwd
            svc.pageFlag = "login"
        }
    }
    
    
    
}//classClose


extension loginViewController {
    
    //adding_Image_on_textField
    func textFieldImageMail(){
        emailMobTextField.rightViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "emailMob")
        imageView.image = image
        emailMobTextField.rightView = imageView
    }
    
    func textFieldImagePin(){
        passwdTextField.rightViewMode = UITextFieldViewMode.always
        let imageView1 = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image1 = UIImage(named: "key")
        imageView1.image = image1
        passwdTextField.rightView = imageView1
    }
    
    //Adding_button_to_textField
    func addButtonToTextField(){
        button.setImage(UIImage(named: "Visa"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        button.frame = CGRect(x: CGFloat(emailMobTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        emailMobTextField.leftView = button
        emailMobTextField.leftViewMode = .always
    }
    
    //text_field_button
    @IBAction func refresh(_ sender: Any) {
        print("text field button clicked")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "modal") as! modalViewController
        //controller.rec = emailMobTextField.text
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //InitRequestForGettingSecretkey
    func loadRequest(){
        let sv = UIViewController.displaySpinner(onView: self.view)
        let http = httpService()
        http.initRequest { (myData) in
            
            print("Data Received---\(myData)")
            
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(initResponse.self, from:
                    myData)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                    }
                    
                    let secPubKey =  model.publicKey
                    let getKey = self.revProcess(value: secPubKey!)
                    Storage.myPublicKey(Key: getKey)
                    
                }
                    
                else {
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        self.Alert(Title: Common.Global.errorTitle, Message: "\(String(describing: model.desc))")
                    }
                }
            }
            catch{
                print("error")
            }
        }
    }
    
    //reverse_process
    func revProcess(value: String) -> String{
        let str = value
        let substring1 = str.dropLast(3)
        let outputString = String(substring1.dropFirst(3))
        //print("After dropping first three and Last three---\(outputString)")
        let reversed = String(outputString.reversed())
        //print("After Reversing a String---\(reversed)")
        
        //print("count value----\(reversed.count)---\(reversed.count/2)")
        
        let arr = reversed.components(withMaxLength: reversed.count/2)
        let first = arr[1]
        let last = arr[0]
        
        //print("arr---\(arr)")
        
        let result = first + last
        //print("Final String is -----\(result)")
        
        return result
    }
    
    
}//ClassClose



extension loginViewController {
    //validatePassword
    func validate(password: String) -> Bool
    {
        let regularExpression = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
        
        let passwordValidation = NSPredicate.init(format: "SELF MATCHES %@", regularExpression)
        
        return passwordValidation.evaluate(with: password)
    }
}

extension loginViewController {
    func toast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
        toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
