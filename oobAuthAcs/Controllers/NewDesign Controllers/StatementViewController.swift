//
//  StatementViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 02/12/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit

class StatementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var statementTableView: UITableView!

    //settingVariables
    var ran1: String?
    var ran2: String?
    
    
    //ArraySetting
    var cardArr = [ReportDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Statements"
        //navigationController?.navigationBar.prefersLargeTitles = true
        statementTableView.delegate = self
        statementTableView.dataSource = self
        
       loadStatements()
        
        //statementTableView.borderWidth = self.view.frame.width
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StatementTableViewCell
        
         cell.frame = CGRect(x: 0, y: 0, width: statementTableView.frame.width, height: statementTableView.frame.height)
        
        cell.merchantName.text = self.cardArr[indexPath.row].merchantName?.uppercased()
        cell.dateTime.text = "On " + convertDateFormatter(date: self.cardArr[indexPath.row].txn_time!)
        
        if self.cardArr[indexPath.row].status == "14" {
            cell.txnAmount.textColor = UIColor.red
        }
        
        else {
            cell.txnAmount.textColor = UIColor(red:0.07, green:0.47, blue:0.27, alpha:1.0)
        }
        
        cell.txnAmount.text = self.cardArr[indexPath.row].txnAmount
        
        return cell
    }
    
    
    func loadStatements(){
        
        //gettingSecKeyfrom--localStoarge
        let userDefaults = UserDefaults.standard
        let secretKey = userDefaults.string(forKey: "secKey")
        let custLoginId = userDefaults.string(forKey: "custId")
        
        //settingModelClass
        let otpReqObj =  StatementReq.init(cust_login_id: custLoginId)
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
        let jsonData = try! jsonEncoder.encode(otpReqObj)
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
        http.call(ClassName: enccRequest, path: "gettransactionhistory") { (mydata) in
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(statementResp.self, from: mydata)
                
                print("Response from completion handler")
                print(model)//Decode JSON Response Data
                
                if (model.rc == "00"){
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        print("Model response-----\(model)")
                        
                        guard let ccd = model.reportDetails else { return }
                        self.cardArr = ccd
                        self.statementTableView.reloadData()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        UIViewController.removeSpinner(spinner: sv)
                        self.Alert(Title: "Sorry", Message: "No Transactions found")
                    }
                }
            }
            catch{
                print("error")
            }
        }
    }
    
   
    
    

}//classClose


extension StatementViewController {
    func convertDateFormatter(date: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.calendar = Calendar(identifier: .iso8601)
        dateFormat.dateFormat = "dd/MM/yyyy hh:mm:ss.SSS"
        let newFormat = DateFormatter()
        newFormat.dateFormat = "EEE MMM dd, H:mm"
        if let date = dateFormat.date(from: date) {
            return newFormat.string(from: date)
        }
        else{
            return ""
        }
    }
}
