//
//  totpViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 13/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import SRCountdownTimer
import SwiftOTP

class totpViewController: UIViewController {

    var counter = 29
    var timer: Timer?
    
    var receivedCid : String?
    var receivedCardNum: String?
    var receivedBrandType: String?
    var cardArr = [Cust_card_details]()
    
    var secretKey: String?
    
    //closeButtonFlag
    var closeFlag: String?
    
    @IBOutlet weak var brandLabel: UIImageView!
    @IBOutlet weak var cardNumLabel: UILabel!
    @IBOutlet weak var genCodeLabel: UILabel!
    @IBOutlet weak var SRcdTimerView: SRCountdownTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // toastLabel.alpha = 0
       self.title = "Soft Token"
        
        print("receivedCid value ----\(String(describing: receivedCid))")
        
        secretKey = fromLocal(custId: receivedCid!)
        secretKey = self.revProcess(value: secretKey!)
        print("Final received key----\(secretKey!)")
        
        navigationItem.largeTitleDisplayMode = .never
        
        genCodeLabel.text = ""
        genCode()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
       startTimer()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let cn = receivedCardNum else {return }
        guard let bt = receivedBrandType else {return }
        
        
        let cardNumber = cn.inserting(separator: "  ", every: 4)
        cardNumLabel.text = cardNumber
        
        if bt == "2" {
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
        //toast(message: "Soft token generated for card number ending with \(cn.suffix(4))")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       timer?.invalidate()
    }
    
    
    @objc func updateCounter(){
        
        if counter > 0 {
            print("\(counter) seconds remaining")
            counter -= 1
        }
        
        else {
            print("Timer over So restarting")
            counter = 29
            startTimer()
            genCode()
        }
    }

    func startTimer(){
        SRcdTimerView.labelFont = UIFont(name: "DIN Alternate", size: 50.0)
        SRcdTimerView.timerFinishingText = "End"
        SRcdTimerView.start(beginingValue: 30, interval: 1)
    }
    
    func genCode(){
        
        //TakingCurrent--UTC--Time
        let currentDateTime = Date()
        print("Time \(currentDateTime)")
        
        guard let data = base32DecodeToData(secretKey!) else { return }
        print("base32DecodeToData----\(data)")
        
        
        if let totp = TOTP(secret: data, digits: 6, timeInterval: 1, algorithm: .sha1) {
            
            let otpString = totp.generate(time: currentDateTime)
            print("TOTP-----\(String(describing: otpString))")
            genCodeLabel.text = otpString!
        }
    }
    
    @IBAction func CloseAction(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    
    
    

}//ClassClose


extension totpViewController {
    func toast(message: String) {
//        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        let toastLabel = UILabel(frame: CGRect(x: 5, y: self.view.frame.size.height-90, width: (self.view.frame.width - 10), height: 60))
        toastLabel.numberOfLines = 3
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 8.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    //getFromLocalStorage
    func fromLocal(custId: String) -> String{
        print("from local storage")
        let userDefaults = UserDefaults.standard
        let test = userDefaults.data(forKey: "custArray")
        
        let decoder = JSONDecoder()
        let model = try! decoder.decode(cardDetailsResp.self, from: test!)
        let cd = model.cust_card_details
        self.cardArr = cd!
        
        let dict :[String: Cust_card_details] = Dictionary(uniqueKeysWithValues:  self.cardArr.map{ ($0.cust_id, $0) }) as! [String : Cust_card_details]
        
        let secretKey = dict[custId]?.secKey
        
         let cardNumber = dict[custId]?.mask_card
        cardNumLabel.text = cardNumber!.inserting(separator: "  ", every: 4)
        
        let ctype =  dict[custId]?.cardType
        
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
        
        return secretKey!
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
}


extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert(separator: Self, every n: Int) {
        for index in indices.reversed() where index != startIndex &&
            distance(from: startIndex, to: index) % n == 0 {
                insert(contentsOf: separator, at: index)
        }
    }
    
    func inserting(separator: Self, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}
