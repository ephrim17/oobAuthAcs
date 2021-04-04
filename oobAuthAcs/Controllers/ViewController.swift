//
//  ViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 16/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - InitProperties
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var alexaToggle: UISwitch!
    @IBOutlet weak var cardNumberTxtField: UITextField!
    @IBOutlet weak var alexaMailTxtField: UITextField!
    @IBOutlet weak var alexaPinTxtField: UITextField!
    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //settingVariables
    var alexaValue : String!
    var alexaEmail: String?
    var alexaSecPin: String?
    var cardNumb: String?
    var ran1: String?
    var ran2: String?
    
    //AuthTypeVariables
    var biometric: Int?
    var alexa: Int?
    var softToken: Int = 3
    var pinAuthentication: Int = 4
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideLayers()
        submitBtn.layer.cornerRadius = 6
        
        //CheckBiometricFlag
        checkFaceandTouchID()
        
        //Adding_Delegate
        alexaPinTxtField.delegate = self
        alexaMailTxtField.delegate = self
        cardNumberTxtField.delegate = self
        self.cardNumberTxtField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //KeyBoardShow__&&__KeyBoardHide
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func alexaToggleActn(_ sender: Any) {
        
        if alexaToggle.isOn {
            alexaValue = "1"
            animateAlexaTextFileds()
        }
            
        else{
            alexaValue = "0"
            inAnimateAlexaTextFields()
        }
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        validate()
        
        //        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //        let newViewController = storyBoard.instantiateViewController(withIdentifier: "home") as! homeViewController
        //       self.navigationController?.pushViewController(newViewController, animated: true)
        
        //self.performSegue(withIdentifier: "otp", sender: self)
        
        
        //
        //        let js = jsCore()
        //        print(js.initializeJS())
        //
        //        let randomNumberFull = js.getRRNfromJS()
        //
        //        let first19 = String("\(randomNumberFull)".prefix(19))
        //        ran1 = "\(first19)"
        //        print("19digits-----\(first19)")
        //
        //        let last8 = String("\(randomNumberFull)".suffix(8))
        //        ran2 = "\(last8)"
        //        print("8digits-----\(last8)")
        //
        //        var encString: String?;
        //
        //        let authType = getAuthType()
        //
        //        let regReq = RegistrationReq(appToken: "hello", deviceID: "xyz", mobModel: "iphone7", emailID: "abcde@wer.com", secPIN: "5577", cardNo: "5577882000000136", isAlexa: 1, isSoftToken: 1, authType: authType)
        //
        //        //Using jsonEncoder to convert it into JSON format
        //        let jsonEncoder = JSONEncoder()
        //        let jsonData = try! jsonEncoder.encode(regReq)
        //        print(jsonData)
        //        let jsonString = String(data: jsonData, encoding: .utf8)
        //        print("Json.Encoder--------> \(String(describing: jsonString))")
        //        //encString_is_the_converted_JSON format for model class
        //        encString = jsonString
        //
        //
        //        let rsaHash = RSAHASH()
        //
        //        //Getting Encrypted RRN
        //        let encRRN = rsaHash.RSAencc(value: ran1!, key: "rsaKeyToBegivenAfterGettingFromServer")
        //
        //        //Getting Encrypted Data
        //        let encData = rsaHash.RSAencc(value: encString!, key: "rsaKeyToBegivenAfterGettingFromServer")
        //
        //        //Getting Hashed Data
        //        let hasheddata = rsaHash.hmacSha(value: encString!, key: ran2!)
        //
        //        print("Hashed Data-------\(hasheddata)")
        //        print("Encrypted RRn-----\(encRRN)")
        //        print("Encrypted Data-----\(encData)")
        //
        //
        //        let Request = EncHashReq(encData: encData, rrn: encRRN, hashedData: hasheddata)
        //        _ = EncHashReq(encData: encData, rrn: encRRN, hashedData: hasheddata)
        //
        //        print("Request Hit---------> \(Request)")
        //
        //
        //        let http = httpService()
        //
        //        http.call(ClassName: Request, path: "customerregistration") { (myData) in
        //            print("Got Result ----\(myData)")
        //        }
    }
    
    
    
    
    func RegisterWithAlexa(cardNum: String?, alexaSecPin: String?, alexaMail: String?, alexaVal: String?, softTokenValue: String?){
        
        guard let cNum = cardNum else {
            return
        }
        guard let asPin = alexaSecPin else {
            return
        }
        guard let aMail = alexaMail else {
            return
        }
        
        guard let deviceInformation = appDelegate.deviceID else {
            return
        }
        
        guard  let deviceModel = appDelegate.model else{
            return
        }
        
        guard let appTokenID = appDelegate.FireBaseTokenID else{
            return
        }
        
        print("received parameters are card Number ----\(cNum), deviceInfo-----\(deviceInformation), deviceModel--- \(deviceModel), alexaMail ---\(aMail), AlexaPin -----\(asPin), appToken----- \(appTokenID)")
        
        
        
        
        //self.performSegue(withIdentifier: "otp", sender: self)
    }
    
    
    func RegisterWithoutAlexa(cardNum: String?, softTokenValue: String?){
        
//        guard let cNum = cardNum else {
//            return
//        }
//        
//        guard let deviceInformation = appDelegate.deviceID else {
//            return
//        }
//        
//        guard  let deviceModel = appDelegate.model else{
//            return
//        }
//        
//        guard let appTokenID = appDelegate.FireBaseTokenID else{
//            return
//        }
//        
//        print("received parameters are card Number ----\(cNum), deviceInfo-----\(deviceInformation), deviceModel--- \(deviceModel), appToken----- \(appTokenID)")
//        
//        let sv = UIViewController.displaySpinner(onView: self.view)
//      
//        
//        
//        let js = jsCore()
//        print(js.initializeJS())
//        
//        let randomNumberFull = js.getRRNfromJS()
//        
//        let first19 = String("\(randomNumberFull)".prefix(19))
//        ran1 = "\(first19)"
//        //print("19digits-----\(first19)")
//        
//        let last8 = String("\(randomNumberFull)".suffix(8))
//        ran2 = "\(last8)"
//        //print("8digits-----\(last8)")
//        
//        var encString: String?;
//        
//        let authType = getAuthType()
//        
//        let regReq = RegistrationReq(appToken: "appTokenID", deviceID: "deviceInformation", mobModel: "deviceModel", emailID: alexaEmail, secPIN: "alexaPinCode", cardNo: "receivedCardNum", authType: "authType", referenceId: "receivedOtpRefId")
//        
//        print("Model class request-----\(regReq)")
//        
//        //Using jsonEncoder to convert it into JSON format
//        let jsonEncoder = JSONEncoder()
//        let jsonData = try! jsonEncoder.encode(regReq)
//        let jsonString = String(data: jsonData, encoding: .utf8)
//        print("Json.Encoder.Model.Class--------> \(String(describing: jsonString))")
//        //encString_is_the_converted_JSON format for model class
//        encString = jsonString
//        
//        
//        let rsaHash = RSAHASH()
//        
//        //Getting Encrypted RRN
//        let encRRN = rsaHash.RSAencc(value: ran1!, key: "rsaKeyToBegivenAfterGettingFromServer")
//        
//        //Getting Encrypted Data
//        let encData = rsaHash.RSAencc(value: encString!, key: "rsaKeyToBegivenAfterGettingFromServer")
//        
//        //Getting Hashed Data
//        let hasheddata = rsaHash.hmacSha(value: encString!, key: ran2!)
//        
//        //print("Hashed Data-------\(hasheddata)")
//        //print("Encrypted RRn-----\(encRRN)")
//        //print("Encrypted Data-----\(encData)")
//        
//        
//        let Request = EncHashReq(encData: encData, rrn: encRRN, hashedData: hasheddata)
//        _ = EncHashReq(encData: encData, rrn: encRRN, hashedData: hasheddata)
//        
//        print("Request Hit---------> \(Request)")
//        
//        
//        
//        let http = httpService()
//
//        http.call(ClassName: Request, path: "customerregistration") { (myData) in
//            DispatchQueue.main.async {
//                UIViewController.removeSpinner(spinner: sv)
//            }
//        }
    }
    
    func validate(){
        alexaSecPin = alexaPinTxtField.text
        cardNumb = cardNumberTxtField.text?.removeWhitespace()
        alexaEmail = alexaMailTxtField.text
        
        if alexaValue == "1"{
            alexa = 2
            
            guard validateEmail(enteredEmail: alexaEmail!) else {
                print("error in email")
                AlertBox(Title: Common.Global.errorTitle, Message: "Please enter the valid mail ID")
                return
            }
            
            guard let alexaPinCode = alexaSecPin, alexaPinCode.count == 4 else {
                print("alexa pin Guard error")
                AlertBox(Title: Common.Global.errorTitle, Message: "Please enter 4 digit Alexa secret pin")
                return
            }
            
            guard let ctemp = cardNumb , ctemp.count == 16  else {
                AlertBox(Title: Common.Global.errorTitle, Message: "Please enter the valid card number")
                return
            }
            
            print("calling Sending params function with alexa")
            RegisterWithAlexa(cardNum: ctemp, alexaSecPin: alexaPinCode, alexaMail: alexaEmail, alexaVal : alexaValue, softTokenValue: "1")
        }
            
        else{
            alexa = nil
            
            guard let ctemp = cardNumb , ctemp.count == 16  else {
                AlertBox(Title: Common.Global.errorTitle, Message: "Please enter the valid card number")
                return
            }
            
            print("calling Sending params function without alexa")
            RegisterWithoutAlexa(cardNum: ctemp, softTokenValue: "1")
        }
        
    }
    
    
    //Check_for_faceID_&_touchID
    func checkFaceandTouchID() {
        if LocalAuth.shared.hasTouchId() {
            print("Has Touch Id")
            biometric = 1
        } else if LocalAuth.shared.hasFaceId() {
            print("Has Face Id")
            biometric = 1
            
        } else {
            biometric = nil
            print("Device does not have Biometric Authentication Method")
        }
    }
    
    //SettingAuthTypeValues
    func getAuthType()->String{
        
        if biometric == 1 && alexa == 2 {
            return "1,2,3,4"
        }
            
        else if biometric == 1 && alexa == nil {
            return "1,3,4"
        }
            
        else if biometric == nil && alexa == 2 {
            return "2,3,4"
        }
            
        else{
            return "1,2,3,4"
        }
    }
    
}//ClassClose

//textFieldShakeAnimation
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}


//RemoveWhiteSpace
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
}


extension ViewController {
    //AlerBox
    func AlertBox (Title: String,Message: String){
        let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //EmailValidation
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    //For_creditCard_Space
    @objc func didChangeText(textField:UITextField)
    {
        textField.text = modifyCreditCardString(creditCardString: textField.text!)
    }
    
    
    func modifyCreditCardString(creditCardString : String) -> String
    {
        let trimmedString = creditCardString.components(separatedBy: .whitespaces).joined()
        
        let arrOfCharacters = Array(trimmedString.characters)
        
        var modifiedCreditCardString = ""
        
        if(arrOfCharacters.count > 0)
        {
            for i in 0...arrOfCharacters.count-1
            {
                modifiedCreditCardString.append(arrOfCharacters[i])
                
                if((i+1) % 4 == 0 && i+1 != arrOfCharacters.count)
                {
                    
                    modifiedCreditCardString.append(" ")
                }
            }
        }
        return modifiedCreditCardString
    }
    
    //KeyBoardShow__and_KeyBoardHide
    @objc func keyboardWillShow(notification: NSNotification, _ textField: UITextField) {
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y = -150
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification, _ textField: UITextField) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Limit_textField_characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = textField.text!.utf8CString.count + string.utf8CString.count - range.length
        
        //print(textField.tag)
        
        if textField.tag == cardNumberTxtField.tag{
            return newLength <= 21
        }
            
        else if textField.tag == alexaPinTxtField.tag{
            return newLength <= 6
        }
            
        else{
            return newLength <= 21
        }
    }
    
    //TextFieldAnimationEffects
    func animateAlexaTextFileds(){
        //Jumper_animation
        //alexaMailTxtField.transform = CGAffineTransform(scaleX: 0, y: 0)
        //alexaPinTxtField.transform = CGAffineTransform(scaleX: 0, y: 0)
        //UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
        //self.alexaMailTxtField.alpha = 1
        //self.alexaPinTxtField.alpha = 1
        //self.alexaMailTxtField.transform = .identity
        //self.alexaPinTxtField.transform = .identity
        //}, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            self.alexaMailTxtField.alpha = 1
            self.alexaPinTxtField.alpha = 1
        }, completion: nil)
    }
    
    func inAnimateAlexaTextFields(){
        //alexaMailTxtField.transform = CGAffineTransform(scaleX: 0, y: 0)
        //alexaPinTxtField.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.alexaMailTxtField.alpha = 0
            self.alexaPinTxtField.alpha = 0
        }, completion: nil)
    }
    
    func hideLayers(){
        alexaMailTxtField.alpha = 0
        alexaPinTxtField.alpha = 0
    }
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.color = UIColor.red
        DispatchQueue.main.async { // Correct
            spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            ai.startAnimating()
            ai.center = spinnerView.center
        }
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}



