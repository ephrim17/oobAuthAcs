//
//  homeViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 01/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import SwiftyJSON
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class homeViewController: UIViewController {
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var sideImage: UIImageView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var sideViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var removeCardBtn: UIButton!
    @IBOutlet weak var softBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var mobileBtn: UIButton!
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsLbe: UIView!
    @IBOutlet weak var alexaBtn: UIButton!
    
    
    //SettingVariables
    var ran1: String?
    var ran2: String?
    var menuShowing = false
    var cardArr = [Cust_card_details]()
    var secKeys : Cust_card_details?
    var sendOtpRefId: String?
    var sendCustId: String?
    
    var offArray = [Cust_card_details]()
    
    //forCells
    let numberOfCells = 9
    let kCellHeight : CGFloat = 100
    let kLineSpacing : CGFloat = 10
    let kInset : CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.white
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        sideMenuImage()
        sideView.isHidden = true
        
        //addingDelegate
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        //buttonSettings
        mobileBtn.layer.cornerRadius = 5
        mobileBtn.backgroundColor = UIColor.black
        addBtn.layer.cornerRadius = 5
        myButton.settings(button: softBtn)
        myButton.settings(button: alexaBtn)
        //myButton.settings(button: mobileBtn)
        
        //settingsView
        //settingsView.roundCorners(corners: [.topLeft, .], radius: 30)
        settingsView.frame.size.width = UIScreen.main.bounds.width
        settingsView.frame.size.height = UIScreen.main.bounds.height
        settingsLbe.frame.size.width =  settingsView.frame.size.width
        settingsLbe.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        settingsView.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //sideView.isHidden = true
        self.cardArr.removeAll()
        if CheckInternet.Connection(){
            print("internet Connected")
            loadCards()
            //ActiveTranRequest()
        }
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
            self.view.backgroundColor = UIColor.white
            fromLocal()
            //printingLocalArray
        }
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    @IBAction func sideMenu(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations:{
            self.sideView.isHidden = false
        })
        
        
        if (menuShowing){
            sideViewConstraint.constant = 0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations:{
                self.view.layoutIfNeeded()
            })
            
            print("menu close")
        }
        else {
            //sideView.isHidden = false
            self.myScrollView.scrollToTop()
            sideViewConstraint.constant = 240
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations:{
                self.view.layoutIfNeeded()
            })
            
            print("menu open")
        }
        menuShowing = !menuShowing
    }
    
    @IBAction func softToken(_ sender: Any) {
        //var key:String?
        var cardNum: String?
        var brandType: String?
        var cust_id: String?
        
        for cell in cardCollectionView.visibleCells {
            let indexPath = cardCollectionView.indexPath(for: cell)
            //guard let secKey = cardArr[(indexPath?.item)!].secKey else {return}
            guard let cid = cardArr[(indexPath?.item)!].cust_id else {return}
            guard let cn = cardArr[(indexPath?.item)!].mask_card else {return}
            guard let bn = cardArr[(indexPath?.item)!].cardType else {return}
            //key = self.revProcess(value: secKey)
            cardNum = cn
            brandType = bn
            cust_id = cid
        }
        
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "totp") as! totpViewController
        newViewController.receivedCid = cust_id
        newViewController.receivedCardNum = cardNum
        newViewController.receivedBrandType = brandType
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        
        //deletingFCM_token
       
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations:{
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "login") as! loginViewController
                let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDel.window?.rootViewController = loginVC
            })
            //clearingLocalStorage_&_Firebase_Token
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            let instance = InstanceID.instanceID()
                   instance.deleteID { (error) in
                       print(error.debugDescription)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func removeBtn(_ sender: Any) {
        
        if CheckInternet.Connection(){
            for cell in cardCollectionView.visibleCells {
                let indexPath = cardCollectionView.indexPath(for: cell)
                print("selected---\(String(describing: cardArr[(indexPath?.item)!].cust_id))")
                print("selected---\(String(describing: cardArr[(indexPath?.item)!].mask_card))")
                guard let cd = cardArr[(indexPath?.item)!].cust_id else {return}
                sendCustId = cd
                deleteCard(cardId: cd)
            }
            
        }
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    
    @IBAction func alexaAction(_ sender: Any) {
        
        if CheckInternet.Connection(){
            for cell in cardCollectionView.visibleCells {
                let indexPath = cardCollectionView.indexPath(for: cell)
                guard let alexaStat = cardArr[(indexPath?.item)!].isAlexaStatus else {return}
                
                if alexaStat {
                    print("alexa already set")
                    let alert = UIAlertController(title: "Update Alexa", message: "Do you want to update Alexa settings", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "alexaUp") as! UpdateAlexaViewController
                        self.navigationController?.pushViewController(newViewController, animated: true)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "cancel", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                    
                else {
                    print("No alexa set")
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "alexa") as! AlexaRegViewController
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }
            }
            
        }
            
        else{
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
        
    }
    
    @IBAction func addCardAction(_ sender: Any) {
        if CheckInternet.Connection(){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "cardReg") as! cardRegViewController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
            
        else {
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    @IBAction func mobileUpdateAction(_ sender: Any) {
        if CheckInternet.Connection(){
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "cardReg") as! cardRegViewController
            newViewController.isUpdate = "1"
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
            
        else {
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
    }
    
    @IBAction func notificationIconAction(_ sender: Any) {
        if CheckInternet.Connection(){
            ActiveTranRequest()
        }
            
        else {
            self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.internetAlertMsge)
        }
        
    }
    
    func showModal(myData : Data) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "activeTran") as! ActiveTranViewController
        newViewController.receivedData = myData
        newViewController.modalPresentationStyle = .overCurrentContext
        self.present(newViewController, animated: true)
    }
    
    
    
    //Side-----------Menu---Button
    @IBAction func statementAction(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "stat") as! StatementViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    @IBAction func changePasswordAction(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "cp") as! changePassViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    //ActiveTranRequest
    func ActiveTranRequest(){
        
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
        let cid = userDefaults.string(forKey: "custId")
        
        //settingModelClass
        let deleteReqObj =  activeTranReq.init(cust_login_id: cid)
        
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
        let jsonData = try! jsonEncoder.encode(deleteReqObj)
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
        http.call(ClassName: enccRequest, path: "getcurrentactivetransaction") { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(activeTranResp.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        //guard let mcName = model.merchantName else {return}
                        //guard let amt = model.txnAmount else {return}
                        self.showModal(myData: mydata)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        
                        //self.Alert(Title: Common.Global.errorTitle, Message: Common.Global.noActiveTran)
                    }
                }
            }
            catch{
                print("error")
            }
        }
    }
    
    
    //deleteCardRequest
    func deleteCard(cardId: String){
        //settingModelClass
        let deleteReqObj =  deleteCardReqOTP.init(cust_id: cardId)
        
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
        let jsonData = try! jsonEncoder.encode(deleteReqObj)
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
        http.call(ClassName: enccRequest, path: "authbyotp") { (mydata) in
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
                        self.performSegue(withIdentifier: "otpDelCard", sender: self)
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
        
        if (segue.identifier == "otpDelCard") {
            let svc = segue.destination as! otpViewController
            svc.receiveotpRefId = sendOtpRefId
            svc.receiveCustId = sendCustId
            svc.pageFlag = "deleteCard"
            
        }
            
        else if (segue.identifier == "backtologin"){
            _ = segue.destination as! loginViewController
        }
    }
    
    
}//classClose

extension homeViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("count ---\(self.cardArr.count)")
        return cardArr.count
        
        // return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let cardNumber = cardArr[indexPath.row].mask_card
        cell.cardNumber.text = cardNumber!.inserting(separator: "  ", every: 4)
        
        if cardArr[indexPath.row].cardType! == "2" {
            //ShowMaster
            DispatchQueue.main.async {
                cell.cardImage.image = UIImage(named: "Master")
            }
        }
        else {
            //ShowVisa
            DispatchQueue.main.async {
                cell.cardImage.image = UIImage(named: "Visa")
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected key ------> \(String(describing: cardArr[indexPath.item].secKey))")
        
        //guard let sk = cardArr[indexPath.item].secKey else { return }
        guard let cn =  cardArr[indexPath.item].mask_card else { return }
        guard let bn = cardArr[indexPath.item].cardType else {return}
        guard let cid = cardArr[(indexPath.item)].cust_id else {return}
        
        //let getKey = self.revProcess(value: sk)
        
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "totp") as! totpViewController
        newViewController.receivedCid = cid
        newViewController.receivedCardNum = cn
        newViewController.receivedBrandType = bn
        self.navigationController?.pushViewController(newViewController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 180)
    }
    
    //loadCardsRequest
    func loadCards(){
        let userDefaults = UserDefaults.standard
        
        //settingModelClass
        let cid = userDefaults.string(forKey: "custId")
        let cardReqObj = cardDetailsReq.init(cust_login_id: cid)
        
        //gettingSecKeyfrom--localStoarge
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
        http.call(ClassName: enccRequest, path: "getcustallcarddetails") { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(cardDetailsResp.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        
                        UIViewController.removeSpinner(spinner: sv)
                        
                        guard let ccd = model.cust_card_details else { return }
                        self.cardArr = ccd
                        
                        
                        //storingInArray--Locally
                        
                        let enc = JSONEncoder()
                        if let encoded = try? enc.encode(model) {
                            let userdefaults = UserDefaults.standard
                            userdefaults.set(encoded, forKey: "custArray")
                        }
                        self.hideEnbaleLayers()
                        self.cardCollectionView.reloadData()
                        
                    }
                    
                }
                else {
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        guard let descResp = model.desc else { return}
                        self.Alert(Title: Common.Global.errorTitle, Message: "\(descResp)")
                        self.hideEnbaleLayers()
                    }
                }
            }
            catch{
                print("error--\(error)")
            }
        }
        
        
        
        func json(from object:Any) -> String? {
            guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
                return nil
            }
            return String(data: data, encoding: String.Encoding.utf8)
        }
    }
    
    
    
}//ClassClose

extension homeViewController {
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
    
    //Side_Menu_Image
    func sideMenuImage(){
        sideImage.layer.cornerRadius = sideImage.frame.size.width / 2
        sideImage.layer.borderColor = UIColor.black.cgColor
        sideImage.layer.borderWidth = 1
        sideImage.clipsToBounds = true
    }
    
    //hideEnbaleLayers
    func hideEnbaleLayers() {
        print("hideEnbaleLayers")
        print("\(cardArr)------\(cardArr.isEmpty)")
        
        
        if self.cardArr.count == 0{
            self.removeCardBtn.alpha = 0.5
            self.softBtn.alpha = 0.5
            self.alexaBtn.alpha = 0.5
            self.mobileBtn.alpha = 0.5
            
            self.mobileBtn.isUserInteractionEnabled = false
            self.softBtn.isUserInteractionEnabled = false
            self.alexaBtn.isUserInteractionEnabled = false
        }
        else {
            self.removeCardBtn.alpha = 1
            self.softBtn.alpha = 1
            self.alexaBtn.alpha = 1
            self.mobileBtn.alpha = 1
            
            self.mobileBtn.isUserInteractionEnabled = true
            self.softBtn.isUserInteractionEnabled = true
            self.alexaBtn.isUserInteractionEnabled = true
        }
        
    }
    
    //getFromLocalStorage
    func fromLocal(){
        print("from local storage")
        let userDefaults = UserDefaults.standard
        let test = userDefaults.data(forKey: "custArray")
        //print(test)
        
        //
        let decoder = JSONDecoder()
        let model = try! decoder.decode(cardDetailsResp.self, from: test!)
        guard let cd = model.cust_card_details else {return}
        self.cardArr = cd
    }
    
    func pulsate(layer: UIButton) {
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}
