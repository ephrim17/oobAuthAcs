//
//  SignUpViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 31/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class cardRegViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var subTitleCard: UILabel!
    @IBOutlet weak var titleCard: UILabel!
    @IBOutlet weak var cardNumTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    //settingVariables
    var cardNumb: String?
    var ran1: String?
    var ran2: String?
    var sendOtpRefId: String?
    var sendCardNum: String?
    var isUpdate: String?
    
    var CheckImageView = UIImageView(frame: CGRect(x: 50, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        //self.title = "Add Card"
        
        myButton.settings(button: submitBtn)
        submitBtn.alpha = 0.5
        submitBtn.isUserInteractionEnabled = false
        
        
        //textFieldBorder
        self.cardNumTextField.addBottomBorder()
        //textFieldImage()
        
        //Tap_Gesture_ToHideKeyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardRegViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //textFieldDelegate
        cardNumTextField.tintColor = .black
        self.cardNumTextField.delegate = self
        self.cardNumTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isUpdate == "1" {
            self.titleCard.text = "Update Card"
            self.subTitleCard.text = "Verify your card number here"
        }
        
        else {
            self.titleCard.text = "Add Card"
            self.subTitleCard.text = "Verify your card number here"
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        if CheckInternet.Connection(){
            print("internet Connected")
            guard let ctemp = cardNumTextField.text?.removeWhitespace() , ctemp.count == 16  else {
                Alert(Title: Common.Global.errorTitle, Message: "Please enter the valid card number")
                return
            }
            //To_send_card_number_toNext_page
            sendCardNum = ctemp
            
            //SendingRequest
            sendRequest(cardNum: ctemp)
        }
            
        else{
           self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    

    @IBAction func cardAction(_ textField: UITextField) {
        //print("TextFieldAction ---called")
        if let number = textField.text?.removeWhitespace() {
            
            if number.isEmpty {
                 textFieldImageHide()
                print("text field should not be empty")
                submitBtn.alpha = 0.5
                submitBtn.isUserInteractionEnabled = false
            }
            
            else if number.count == 16 {
                print("text field  --\(number.count)")
                submitBtn.alpha = 1
                submitBtn.isUserInteractionEnabled = true
                
                let js = jsCore()
                print(js.initializeJS())
                
                let brandName = js.cardBrandName(cc: number)
                print("BrandName-----\(brandName)")
                
                if brandName == "Master" {
                    //ShowMaster
                    textFieldImageShow(brand: brandName)
                }
                
                else if brandName == "Visa" {
                    //ShowVisa
                     textFieldImageShow(brand: brandName)
                }
                
                else if brandName == "Rupay" {
                    //ShowRupay
                    textFieldImageShow(brand: brandName)
                }
                
                else if brandName == "errorCard" {
                    //ShowError
                    textFieldImageShow(brand: brandName)
                    DispatchQueue.main.async {
                        self.Alert(Title: "Error", Message: "Please enter valid card")
                    }
                }
                
            }
                
                
            else{
                textFieldImageHide()
                print("text field should not be empty")
                submitBtn.alpha = 0.5
                submitBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    func sendRequest(cardNum: String){
        //settingModelClass
        let cardReqObj : cardAuthReq?
        
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
        let cid = userDefaults.string(forKey: "custId")
        
        if isUpdate == "1" {
             cardReqObj =  cardAuthReq.init(cardNo: cardNum, cust_login_id: cid, isUpdate: true)
        }
        
        else {
            cardReqObj =  cardAuthReq.init(cardNo: cardNum, cust_login_id: cid, isUpdate: nil)
        }

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
        http.call(ClassName: enccRequest, path: "authcustomer") { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(cardAuthResp.self, from: mydata)

                print("Response from completion handler")
                print(model)//Decode JSON Response Data

                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        guard let otpRefId = model.reference_id else { return}
                        self.sendOtpRefId = otpRefId
                        self.performSegue(withIdentifier: "addCardOtp", sender: self)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        guard let descResp = model.desc else { return}
                        self.AlertBox(Title: Common.Global.errorTitle, Message: "\(descResp)")
                    }
                }
            }
            catch{
                print("error")
            }
        }
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "addCardOtp") {
            let svc = segue.destination as! otpViewController
            svc.receiveotpRefId = sendOtpRefId
            svc.receivecardNum = sendCardNum
            svc.pageFlag = "addCard"
        }
    }
    
}//classClose

extension cardRegViewController{
    
    //AlerBox
    func AlertBox (Title: String,Message: String){
        let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //Calls this function when the tap is recognized
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    
    //Limit_textField_characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = textField.text!.utf8CString.count + string.utf8CString.count - range.length
        
        //print(textField.tag)
        
        if textField.tag == cardNumTextField.tag{
            return newLength <= 21
        }
            
        else{
            return newLength <= 21
        }
    }
    
    //adding_Image_on_textField
    func textFieldImage(){
        cardNumTextField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "cards")
        imageView.image = image
        cardNumTextField.leftView = imageView
    }
    
    func textFieldImageShow(brand:String){
        CheckImageView.isHidden = false
        cardNumTextField.rightViewMode = UITextFieldViewMode.always
        //let image = UIImage(named: "\(brand)")
        let image = UIImage(named: "master2")
        CheckImageView.image = image
        CheckImageView.clipsToBounds = true
        CheckImageView.contentMode = .scaleAspectFit
        cardNumTextField.rightView = CheckImageView
    }
    
    func textFieldImageHide(){
        CheckImageView.isHidden = true
    }
}


