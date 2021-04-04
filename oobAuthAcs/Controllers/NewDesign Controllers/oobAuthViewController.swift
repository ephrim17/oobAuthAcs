//
//  oobAuthViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 21/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import LocalAuthentication
import Lottie

class oobAuthViewController: UIViewController {
    
    @IBOutlet weak var RedStatusLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var brandImageLabel: UIImageView!
    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var cardArr = [Cust_card_details]()
    
    //SettingVariables
    var ran1: String?
    var ran2: String?
    var tranId: String?
    var custId: String?
    var toUrl: String?
    var receiveCustId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let cid = receiveCustId else {return} //gettingCustID from App delegate
        fromLocal(custId: cid)
    }
    
    
    //getFromLocalStorage
    func fromLocal(custId: String){
        print("from local storage")
        let userDefaults = UserDefaults.standard
        let test = userDefaults.data(forKey: "custArray")
        
        let decoder = JSONDecoder()
        let model = try! decoder.decode(cardDetailsResp.self, from: test!)
        guard let cd = model.cust_card_details else {return}
        self.cardArr = cd
        
        let dict :[String: Cust_card_details] = Dictionary(uniqueKeysWithValues:  self.cardArr.map{ ($0.cust_id, $0) }) as! [String : Cust_card_details]
        
        guard let cardNumber = dict[custId]?.mask_card else {return}
        cardNumberLabel.text = cardNumber.inserting(separator: "  ", every: 4)
        
        guard let ctype =  dict[custId]?.cardType else {return}
        
        if ctype == "2" {
            //ShowMaster
            DispatchQueue.main.async {
                self.brandImageLabel.image = UIImage(named: "Master")
            }
        }
        else {
            //ShowVisa
            DispatchQueue.main.async {
                self.brandImageLabel.image = UIImage(named: "Visa")
            }
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
         self.authenticationWithTouchID()
//        let alert = UIAlertController(title: "Do you want to continue with transaction?", message: "click Yes to approve and NO to cancel", preferredStyle: .alert)
//
//
//        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
//            print("No clicked!!")
//            _ = UIViewController.displaySpinner(onView: self.view)
//            print("Cancelled By user")
//        }))
//
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//            print("yes clicked!!")
//            self.authenticationWithTouchID()
//        }))
//        self.present(alert, animated: true)
        
    }
}

extension oobAuthViewController {
    func authenticationWithTouchID() {
        let context = LAContext()
        var error: NSError?
        
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "For Successfull Authentication"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    
                    if success {
                        print("success")
                        DispatchQueue.main.async {
                            self.sendSuccess()
                        }
                    }
                    else {
                        print("sendFailure")
                        DispatchQueue.main.async {
                            self.sendFailure()
                    }
                }
            })
        }
        else {
            //AlertBox(Title: "Alert", Message: "Touch ID not available")
            print("Touch ID not available")
            
            DispatchQueue.main.async {
                //self.view.removeFromSuperview()
                self.view.backgroundColor = UIColor.white
                self.notAvailableLottie()
                self.Alert(Title: "Sorry", Message: "Authentication type is not available on your device")
                self.RedStatusLabel.text = "Sorry Authentication type is not available on your device"
                
            }
        }
    }
}

extension oobAuthViewController{
    func loadSuccessLottie(){
        let animationView = AnimationView(name: "checked-done")
        animationView.frame = CGRect(x: self.view.frame.midX, y: self.view.frame.midY + 80, width: self.view.frame.width, height: 200)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.center = self.view.center
        animationView.play()
        view.addSubview(animationView)
    }
    
    func loadErrorLottie(){
        let animationView = AnimationView(name: "cancel-error")
        animationView.frame = CGRect(x: self.view.frame.midX, y: self.view.frame.midY + 80, width: self.view.frame.width, height: 200)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.center = self.view.center
        animationView.play()
        view.addSubview(animationView)
    }
    
    func notAvailableLottie(){
        let animationView = AnimationView(name: "not-Available")
        animationView.frame = CGRect(x: 16, y: 407, width: 343, height: 232)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.center = self.view.center
        animationView.play()
        view.addSubview(animationView)
    }
    
    
    func sendSuccess() {
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        //SettingModelClassObjects
        //tranId = appDelegate.tranID
        //custId = appDelegate.custID
        //toUrl = appDelegate.givenURL
        
        let authObj = authenticationReq.init(tranId: tranId, custId: receiveCustId, authType: "biometric", rc: "00", desc: "success")
        
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
        let jsonData = try! jsonEncoder.encode(authObj)
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
        http.authenticationCall(ClassName: enccRequest, givenUrl: toUrl!) { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(authenticationRes.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        self.loadSuccessLottie()
                        self.RedStatusLabel.text = "Your Authentication was Successfull"
                        self.Alert(Title: "Authentication was Successfull", Message: nil)
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
    
    func sendFailure() {
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        //SettingModelClassObjects
        tranId = appDelegate.tranID
        custId = appDelegate.custID
        toUrl = appDelegate.givenURL
        
        let authObj = authenticationReq.init(tranId: tranId, custId: receiveCustId, authType: "biometric", rc: "01", desc: "failure")
        
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
        let jsonData = try! jsonEncoder.encode(authObj)
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
        http.authenticationCall(ClassName: enccRequest, givenUrl: toUrl!) { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(authenticationRes.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "01"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                       self.loadErrorLottie()
                    self.RedStatusLabel.text = "Sorry Your Authentication was failed"
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
