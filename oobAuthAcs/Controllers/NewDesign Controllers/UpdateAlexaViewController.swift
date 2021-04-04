//
//  UpdateAlexaViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 05/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class UpdateAlexaViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var secpinTextField: UITextField!
    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //settingVariables
    var alexaValue : String!
    var alexaEmail: String?
    var alexaSecPin: String?
    var cardNumb: String?
    var ran1: String?
    var ran2: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpdateAlexaViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //addingdelegates
        self.emailTxtField.delegate = self
        self.secpinTextField.delegate = self
        emailTxtField.tintColor = .black
        secpinTextField.tintColor = .black
        emailTxtField.addBottomBorder()
        secpinTextField.addBottomBorder()
        
         let txtSettings = textFieldSetting()
        txtSettings.textFieldImageMail(txtfield: emailTxtField)
        txtSettings.textFieldImageKey(txtfield: secpinTextField)
    }
    
    @IBAction func updateAction(_ sender: Any) {
        
        alexaEmail = emailTxtField.text
        alexaSecPin = secpinTextField.text
        
        let validation = validationService()
        
        guard validation.validateEmail(enteredEmail: alexaEmail!) else {
            print("error in email")
            Alert(Title: Common.Global.errorTitle, Message: "Please enter the valid mail ID")
            return
        }
        
        guard let alexaPinCode = alexaSecPin, alexaPinCode.count == 4 else {
            print("alexa pin Guard error")
            Alert(Title: Common.Global.errorTitle, Message: "Please enter 4 digit Alexa secret pin")
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
        
        let userDefaults = UserDefaults.standard
        let cid = userDefaults.string(forKey: "custId")
        print("cid from localStorage is \(String(describing: cid))")
        
        let reqObj = alexaUpdateReq.init(emailID: alexaEmail, secPIN: alexaSecPin, cust_id: cid!)
        
        //gettingSecKeyfrom--localStoarge
        let secretKey = userDefaults.string(forKey: "secKey")
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        print("Model class request-----\(reqObj)")
        
        //Using jsonEncoder to convert it into JSON format
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(reqObj)
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
        
        http.call(ClassName: Request, path: "customeralexaregistration") { (mydata) in
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
                        UIViewController.removeSpinner(spinner: sv)
                       //let alert = UIAlertController(title: "Success", message: "User details updated successfully", preferredStyle: UIAlertController.Style.alert)
                        //alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { action in
                        //self.performSegue(withIdentifier: "homeAlexa", sender: self)
                        //}))
                        
                        // show the alert
                        //self.present(alert, animated: true, completion: nil)
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
    
    
    
    

}//ClassClose


extension UpdateAlexaViewController{
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //EmailValidation
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    //Limit_textField_characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = textField.text!.utf8CString.count + string.utf8CString.count - range.length
        
        //print(textField.tag)
        
        if textField.tag == secpinTextField.tag{
            return newLength <= 6
        }
            
        else{
            return newLength <= 100
        }
    }
    
    //adding_Image_on_textField
    func textFieldImageMail(){
        emailTxtField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "mail")
        imageView.image = image
        emailTxtField.leftView = imageView
    }
    
    func textFieldImagePin(){
        secpinTextField.leftViewMode = UITextFieldViewMode.always
        let imageView1 = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image1 = UIImage(named: "key")
        imageView1.image = image1
        secpinTextField.leftView = imageView1
    }
}
