//
//  signUpViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 14/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class signUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailIDtextField: UITextField!
    //@IBOutlet weak var mobTextField: FPNtexfield!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var mobTextField: FPNTextField!
    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //sendingVariables
    var EmailtoSent: String?
    var mobNumbtoSent: String?
    var sendOtpRefId: String?
    
    //settingVariables
    var ran1: String?
    var ran2: String?
    var dialCode = "+91"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myButton.settings(button: submitBtn)
        
        if CheckInternet.Connection(){
            print("internet Connected")
            loadRequest()
//            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
//                myAlert.Show(vc: signUpViewController(), Title: "dw", Message: "wd")
//            }
          
        }
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
        
        
       
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardRegViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //addingDelegates
        emailIDtextField.delegate = self
        initializeFPN()
        
        //let txtSettings = textFieldSetting()
        //txtSettings.textFieldImageMail(txtfield: emailIDtextField)
        
        
        
        emailIDtextField.addBottomBorder()
        mobTextField.addBottomBorder()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        if CheckInternet.Connection(){
            print("internet Connected")
            guard let Email = emailIDtextField.text else { return }
            guard let mobNumb = mobTextField.text?.removeWhitespace().replacingOccurrences(of: "-", with: "") else { return }
            
            EmailtoSent =  Email
            mobNumbtoSent = dialCode.replacingOccurrences(of: "+", with: "") + mobNumb
            
            //print("EmailtoSent--\(EmailtoSent)---mobNumbtoSent--\(mobNumbtoSent)")
            
            
            let validate = validationService()
            
            guard validate.validateEmail(enteredEmail: Email) else {
                Alert(Title: Common.Global.errorTitle, Message: "Please Enter Valid Email-ID")
                return
            }
            
            guard validate.validateNumb(value: dialCode + mobNumb) else {
                print("error Mobile Number---\(mobNumb)")
                Alert(Title: Common.Global.errorTitle, Message: "Please Enter Valid Mobile Number")
                return
            }
            
            print("Send Request---\(Email)---\(mobNumb)")
            sendRequest(em: EmailtoSent!, mn: mobNumbtoSent!)
        }
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    
    @IBAction func alreadyAction(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    //SendingOTP--Request
    func sendRequest(em: String, mn: String){
        
        //settingModelClass
        let otpReqObj =  otpReq.init(emailAddr: em, mobileNo: mn, isVerify: 0)
        
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
                        self.performSegue(withIdentifier: "otpSignUp", sender: self)
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
        
        if (segue.identifier == "otpSignUp") {
            //let nav = segue.destination as! UINavigationController
            //_ = nav.topViewController as! homeViewController
            //svc.toPassSearchKeyword = searchKeyword;
            
            //let svc = segue.destination as! setPassViewController
            //svc.email = EmailtoSent
            //svc.refId = sendOtpRefId
            //svc.mobNum = mobNumbtoSent
            
            let svc = segue.destination as! otpViewController
            svc.receiveotpRefId = sendOtpRefId
            svc.receiveEmail = EmailtoSent
            svc.receiveMobNum = mobNumbtoSent
        }
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
    

}//classClose


extension signUpViewController{
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //initilaiseFPN_textField
    func initializeFPN(){
        // Comment this line to not have access to the country list
        mobTextField.parentViewController = self
        mobTextField.delegate = self
        
        // Custom the size/edgeInsets of the flag button
        mobTextField.flagSize = CGSize(width: 35, height: 35)
        mobTextField.flagButtonEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        mobTextField.hasPhoneNumberExample = true
    }

}

extension String {
    var withoutSpecialCharacters: String {
        return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
}


extension signUpViewController: FPNTextFieldDelegate {
    
    func fpnDidValidatePhoneNumber
        (textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        //        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
        //textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
//        print(
//            isValid,
//            textField.getFormattedPhoneNumber(format: .E164),
//            textField.getFormattedPhoneNumber(format: .International),
//            textField.getFormattedPhoneNumber(format: .National),
//            textField.getFormattedPhoneNumber(format: .RFC3966),
//            textField.getRawPhoneNumber()
//
//        )
        if isValid == true {
//            submitBtn.isEnabled = true
//            submitBtn.alpha = 1
        }
            
        else{
//            submitBtn.isEnabled = false
//            submitBtn.alpha = 0.5
        }
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
        self.dialCode = dialCode
    }
    
    
    
}
