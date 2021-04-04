//
//  chooseAuthViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 21/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class chooseAuthViewController: UIViewController {

    
    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var jsContext: JSContext!
    var buttonLayerValue :CGFloat = 18
    
    @IBOutlet weak var oobBtn: UIButton!
    @IBOutlet weak var softBtn: UIButton!
    @IBOutlet weak var alexaBtn: UIButton!
    @IBOutlet weak var pinAuth: UIButton!
    
    //cardView
    var receiveCustID : String?
    var receiveTranId: String?
    var receiveUrl: String?
    var cardArr = [Cust_card_details]()
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var brandImageLabel: UIImageView!
    
    var myArr = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myButton.settings(button: oobBtn)
        myButton.settings(button: alexaBtn)
        
        guard let cid = receiveCustID else {return} //gettingCustID from App delegate
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
    
    
    @IBAction func oobAction(_ sender: Any) {
        self.performSegue(withIdentifier: "Auth", sender: self)
    }
    
    @IBAction func softAction(_ sender: Any) {
        print("clicked soft token page")
        self.performSegue(withIdentifier: "softToken", sender: self)
    }
    
    @IBAction func alexaAction(_ sender: Any) {
        
    }
    
    @IBAction func pinAction(_ sender: Any) {
         print("clicked pin auth page")
         self.performSegue(withIdentifier: "pin", sender: self)
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any!) {
        
        if (segue.identifier == "softToken") {
            _ = segue.destination as! softTokenViewController
        }
        
        else if (segue.identifier == "Auth") {
            let svc  = segue.destination as! oobAuthViewController
            svc.receiveCustId = self.receiveCustID
            svc.tranId = receiveTranId
            svc.toUrl = receiveUrl
        }
        
        else if (segue.identifier == "pin") {
            _ = segue.destination as! pinViewController
        }
    }
    
}

extension chooseAuthViewController{

}
