//
//  setPassViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 13/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class setPassViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    //ReceiveVariables
    var email: String?
    var mobNum: String?
    var refId: String?
    
    //settingVariables
    var passWd: String?
    var ran1: String?
    var ran2: String?
    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myButton.settings(button: submitBtn)
    
        //guard let mn = mobNum else { return }
        //guard let em = email else { return }

        print("Received Variables --- \(String(describing: email))---\(String(describing: mobNum))--\(String(describing: refId))")
        
        //addingDelegates
        passTextField.delegate = self
        confirmPassTextField.delegate = self
        passTextField.addBottomBorder()
        confirmPassTextField.addBottomBorder()
        
        //let tfSetting = textFieldSetting()
        //tfSetting.textFieldImageKey(txtfield: passTextField)
        //tfSetting.textFieldImageKey(txtfield: confirmPassTextField)

        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardRegViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        
        
        if passTextField.text == ""  || confirmPassTextField.text == "" {
            Alert(Title: Common.Global.errorTitle, Message: "Password Fields should not be empty")
        }
            
        else if passTextField.text == confirmPassTextField.text{
            print("Pin Match")
            
            guard let ps =  passTextField.text else {return}
            passWd = ps
            
            let validation = validationService()
            
            guard validation.validatePass(password: ps) else {
                return
                 Alert(Title: Common.Global.errorTitle, Message: "Password should contain atleast 8 characters, 1 uppercase and 1 number")
            }
            
            guard let mn = mobNum else { return }
            guard let em = email else { return }
            sendRequest(email: em, mnumb: mn, pwd: ps)
        }
            
        else if passTextField.text != confirmPassTextField.text{
            print("Pin Not Match")
            Alert(Title: Common.Global.errorTitle, Message: "Passwords does not Match")
        }
    }
    
    
    func sendRequest(email: String, mnumb: String, pwd: String){
        
        if CheckInternet.Connection(){
            print("internet Connected")
            //settingModelClass
            
            guard let aptkn = appDelegate.FireBaseTokenID else { return }
            
            let signUpReqObj =  signUpReq.init(emailAddr: email, mobileNo: mnumb, passWord: pwd, reference_id: refId, appToken : aptkn)
            
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
            let jsonData = try! jsonEncoder.encode(signUpReqObj)
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
            http.call(ClassName: enccRequest, path: "signup") { (mydata) in
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(signUpResp.self, from: mydata)
                    
                    print(model)//Decode JSON Response Data
                    
                    if (model.rc == "00"){
                        DispatchQueue.main.async {
                            UIViewController.removeSpinner(spinner: sv)
                            guard let msg = model.desc else { return}
                            guard let custid = model.cust_login_id else {return}
                            Storage.customerId(cid: custid)
                            Storage.loginFlag(flag: "true")
                            let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                                print("Navigate to Home")
                                self.performSegue(withIdentifier: "home", sender: self)
                                
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
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "home") {
            print("Navigating to home")
            let nav = segue.destination as! UINavigationController
            _ = nav.topViewController as! homeViewController
        }
    }
    

}//classClose


extension setPassViewController {
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
