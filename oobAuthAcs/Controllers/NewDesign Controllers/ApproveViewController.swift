//
//  ApproveViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 22/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class ApproveViewController: UIViewController {

    //to-access-appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var merchantLabel: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        declineBtn.layer.cornerRadius = 5
        approveBtn.layer.cornerRadius = 5
        
        merchantLabel.text = appDelegate.merchant_name
        amount.text = appDelegate.currency_symbol! + " " + appDelegate.txn_amt!
    }
    
    
    @IBAction func approveAction(_ sender: Any) {
        
        guard let auth = appDelegate.authTypeValue else { return }
        
        if auth == "0" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "chooseAuth") as! chooseAuthViewController
            controller.receiveCustID = appDelegate.custID
            controller.receiveUrl = appDelegate.givenURL
            controller.receiveTranId = appDelegate.tranID
             controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
        
        else if auth == "3" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "totp") as! totpViewController
            controller.receivedCid = appDelegate.custID
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
        
        else if auth == "4" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "pin") as! pinViewController
            controller.receiveCustId = appDelegate.custID
            controller.toUrl = appDelegate.givenURL
            controller.receiveTranId = appDelegate.tranID
             controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func declineAction(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: "Are you sure you want to decline this request", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            
            print("send cancel request")
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            print("do nothing")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
