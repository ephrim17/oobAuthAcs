//
//  pinViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 05/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import Lottie

class pinViewController: UIViewController {
    
    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //Button_number_variables
    var number1: String?
    var number2: String?
    var number3: String?
    
    //SettingVariables
    var ran1: String?
    var ran2: String?
    var receiveTranId: String?
    var custId: String?
    var toUrl: String?
    var cardArr = [Cust_card_details]()
    var receiveCustId : String?
    
    
    @IBOutlet weak var brandLabel: UIImageView!
    @IBOutlet weak var cardNumbLabel: UILabel!
    @IBOutlet weak var redStatusLabel: UILabel!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Making_round_button
        btn1.layer.cornerRadius = 0.5 * btn1.bounds.size.width
        btn1.clipsToBounds = true
        btn2.layer.cornerRadius = 0.5 * btn2.bounds.size.width
        btn2.clipsToBounds = true
        btn3.layer.cornerRadius = 0.5 * btn3.bounds.size.width
        btn3.clipsToBounds = true
        
        guard let cid = receiveCustId else {return} //gettingCustID from active tran VC
        fromLocal(custId: cid)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Separating_the_three_numbers
        guard let threeNumbers = appDelegate.gPin else { return }
        print("Received three numbers are \(threeNumbers)")
        let fullNumArr = threeNumbers.components(separatedBy: ",")
        number1 = "\(fullNumArr[0])"
        number2 = "\(fullNumArr[1])"
        number3 = "\(fullNumArr[2])"
        
        //Setting_numbers_to_button
        btn1.setTitle(number1,for: .normal)
        btn2.setTitle(number2,for: .normal)
        btn3.setTitle(number3,for: .normal)
    }
    
    
    @IBAction func btn1Action(_ sender: Any) {
        print("Clicked number---\(String(describing: number1))")
        sendRequest(number: number1!)
    }
    
    
    @IBAction func btn2Action(_ sender: Any) {
        print("Clicked number---\(String(describing: number2))")
        sendRequest(number: number2!)
    }
    
    
    @IBAction func btn3Action(_ sender: Any) {
        print("Clicked number---\(String(describing: number3))")
        sendRequest(number: number3!)
    }
    
    
}//classClose


extension pinViewController {
    
    func loadSuccessLottie(){
        hideLayers()
        let animationView = AnimationView(name: "checked-done")
        animationView.frame = CGRect(x: 16, y: 407, width: 343, height: 232)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.center = self.view.center
        animationView.play()
        view.addSubview(animationView)
    }
    
    func loadErrorLottie(){
        hideLayers()
        let animationView = AnimationView(name: "cancel-error")
        animationView.frame = CGRect(x: 16, y: 407, width: 343, height: 232)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.center = self.view.center
        animationView.play()
        view.addSubview(animationView)
    }
    
    func hideLayers(){
        btn1.alpha = 0
        btn2.alpha = 0
        btn3.alpha = 0
    }
    
    func sendRequest(number: String){
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        //SettingModelClassObjects
        //tranId = appDelegate.tranID
        //custId = appDelegate.custID
        //toUrl = appDelegate.givenURL
        
        let pinReqObj = validatePinReq.init(tranId: receiveTranId, encPin: number, custId: receiveCustId)
        print("pinreqObj----\(pinReqObj)")
        
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
        let jsonData = try! jsonEncoder.encode(pinReqObj)
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
                let model = try decoder.decode(validatePinResp.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        print("Pin Verification Successful")
                        self.loadSuccessLottie()
                        self.redStatusLabel.text = "Your Authentication was Successfull"
                        self.Alert(Title: "Authentication success", Message: nil)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        self.loadErrorLottie()
                        self.redStatusLabel.text = "Sorry Your Authentication was Failed"
                        self.Alert(Title: "Authentication success", Message: nil)
                    }
                }
            }
            catch{
                print("error")
            }
        }
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
        cardNumbLabel.text = cardNumber.inserting(separator: "  ", every: 4)
        
        guard let ctype =  dict[custId]?.cardType else {return}
        
        if ctype == "2" {
            //ShowMaster
            DispatchQueue.main.async {
                self.brandLabel.image = UIImage(named: "Master")
            }
        }
        else {
            //ShowVisa
            DispatchQueue.main.async {
                self.brandLabel.image = UIImage(named: "Visa")
            }
        }
        
    }
}

