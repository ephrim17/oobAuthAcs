//
//  ActiveTranViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 28/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class ActiveTranViewController: UIViewController {
    
    
    @IBOutlet weak var merchantLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    
    
    //settingVariables
    var merchantName : String?
    var amount: String?
    var receivedData : Data?
    var authType: String?
   
    //sendingVariables
    var sendCustId: String?
    var sendUrl: String?
    var sendTranId: String?
    
    
    
    
    override func viewDidLoad() {
        view?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        acceptBtn.layer.cornerRadius = 5
        view.isOpaque = true
        
        
        let decoder = JSONDecoder()
        let model = try! decoder.decode(activeTranResp.self, from: receivedData!)
        print("ActiveTranViewController")
        print(model)//Decode JSON Response Data
        
        guard let mcN = model.merchantName else {return}
        merchantLabel.text = mcN
        
        guard let amt = model.txnAmount else {return}
        amountLabel.text = amt
        
        //to--ther--VC
        guard let atype = model.authType else {return}
        authType = atype
        
        guard let cid = model.custId else {return}
        sendCustId = cid
        
        guard let tid = model.tranId else {return}
        sendTranId = tid
        
        guard let url = model.url else {return}
        sendUrl = url
    }
    
    
    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func approveAction(_ sender: Any) {
        
        if authType == "0" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "chooseAuth") as! chooseAuthViewController
            controller.receiveCustID = sendCustId
            controller.receiveTranId = sendTranId
            controller.receiveUrl = sendUrl
            self.present(controller, animated: true, completion: nil)
        }
            
        else if authType == "3" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "totp") as! totpViewController
            controller.receivedCid = sendCustId
            self.present(controller, animated: true, completion: nil)
        }
            
        else if authType == "4" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "pin") as! pinViewController
            controller.receiveCustId = sendCustId
            controller.toUrl = sendUrl
            controller.receiveTranId = sendTranId
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
}
