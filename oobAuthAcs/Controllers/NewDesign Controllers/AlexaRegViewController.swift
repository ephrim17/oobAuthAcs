//
//  AlexaRegViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 01/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class AlexaRegViewController: UIViewController, UITextFieldDelegate {
    
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
    var receivedOtpRefId: String?
    var receivedCardNum: String?
    
    
    @IBOutlet weak var alexaToggle: UISwitch!
    @IBOutlet weak var cardHeight: NSLayoutConstraint!
    @IBOutlet weak var alexaEmailTextField: UITextField!
    @IBOutlet weak var alexaSecPinTextField: UITextField!
    @IBOutlet weak var SubmitBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AlexaReg view controller")
        //print("Received Otp ref Id ----\(String(describing: receivedOtpRefId))")
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AlexaRegViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //SmallCardView--&&--hideLayers
        //self.cardHeight.constant = 120
        
        //addingdelegates
        alexaEmailTextField.tintColor = .black
        alexaSecPinTextField.tintColor = .black
        self.alexaEmailTextField.delegate = self
        self.alexaSecPinTextField.delegate = self
        alexaEmailTextField.addBottomBorder()
        alexaSecPinTextField.addBottomBorder()
        
        
        //buttonLayers
        myButton.settings(button: SubmitBtn)
        
        //addingImageIntextField
        //textFieldImagePin()
        //textFieldImageMail()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        validateWithAlexa()
    }
    

    func validateWithAlexa(){
        
        guard validateEmail(enteredEmail: alexaEmail!) else {
            print("error in email")
            Alert(Title: Common.Global.errorTitle, Message: "Please enter the valid mail ID")
            return
        }
        
        guard let alexaPinCode = alexaSecPin, alexaPinCode.count == 4 else {
            print("alexa pin Guard error")
            Alert(Title: Common.Global.errorTitle, Message: "Please enter 4 digit Alexa secret pin")
            return
        }
        
        print("calling with alexa")
        
        
        
        
    }
    
}//ClassClose
//
extension AlexaRegViewController{
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
        
        if textField.tag == alexaSecPinTextField.tag{
            return newLength <= 6
        }

        else{
            return newLength <= 100
        }
    }
    
    /*RegisteredSuccessFully
     .
     .
     .
     .
     .
     .*/
    
    //adding_Image_on_textField
    func textFieldImageMail(){
        alexaEmailTextField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "mail")
        imageView.image = image
        alexaEmailTextField.leftView = imageView
    }
    
    func textFieldImagePin(){
        alexaSecPinTextField.leftViewMode = UITextFieldViewMode.always
        let imageView1 = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image1 = UIImage(named: "key")
        imageView1.image = image1
        alexaSecPinTextField.leftView = imageView1
    }
}
