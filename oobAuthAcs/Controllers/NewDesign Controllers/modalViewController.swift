//
//  modalViewController.swift
//  oobAuthAcs
//
//  Created by LOB4 on 12/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import UIKit
import SwiftyJSON


//To_pass_value_to_previous_VC
protocol DataEnteredDelegate: class {
    func userDidEnterInformation(info: String)
}

class modalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    
    //To_pass_value_to_previous_VC
    weak var delegate: DataEnteredDelegate? = nil
    
    
    //Array_Values_for_DialCode_&&_CountryName
    var dialCodeArr = [String]()
    var countryNameArr = [String]()
    
    //for searchBar
    var filteredCountryData: [String]!
    var filteredCodeData: [String]!
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    
    @IBOutlet weak var countryTableView: UITableView!
    @IBOutlet weak var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryTableView.delegate = self
        countryTableView.dataSource = self
        loadJSON()
        loadSearchBar()
    }
    

    @IBAction func closeAction(_ sender: Any) {
        //delegate?.userDidEnterInformation(info: "+91")
        dismiss(animated: true, completion: nil)
    }
    
    
    //Update_Search_Results
    func updateSearchResults(for searchController: UISearchController) {
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (dialCodeArr as NSArray).filtered(using: searchPredicate)
        let array2 = (countryNameArr as NSArray).filtered(using: searchPredicate)
        filteredCodeData = array as? [String]
        filteredCountryData = array2 as? [String]
        
        self.countryTableView.reloadData()
    }
    
    
    
    //Return_number_of_Table_count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  (resultSearchController.isActive) {
            return filteredCountryData.count
        } else {
            return dialCodeArr.count
        }
        //return dialCodeArr.count
    }
    
    //Returns_the_cells_with_ArrayValues
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! countryTableViewCell
        
        if (resultSearchController.isActive) {
            cell.countryName?.text = filteredCountryData[indexPath.row]
            
            let a: String?
            a = filteredCountryData[indexPath.row]
            let number : Int = countryNameArr.firstIndex(of: a!)!
            cell.countryCode?.text =  self.dialCodeArr[number]
            
            return cell
        }
        else{
            cell.countryName.text = countryNameArr[indexPath.row]
            cell.countryCode.text = dialCodeArr[indexPath.row]
            
            //cell.countryImage.image = logoImage[0]
            return cell
        }
       
    }
    
    
    //Sending_the_selected_cellValue_to_previous_VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        if (resultSearchController.isActive) {
            let a: String?
            a = filteredCountryData[indexPath.row]
            let number : Int = countryNameArr.firstIndex(of: a!)!

             print("You selected country code: \(self.dialCodeArr[number])")
            
            delegate?.userDidEnterInformation(info: "\(self.dialCodeArr[number])")
            dismiss(animated: true, completion: nil)
            dismiss(animated: true, completion: nil)
        }
            
        else {
             print("You selected country code: \(dialCodeArr[indexPath.row])")
            delegate?.userDidEnterInformation(info: "\(dialCodeArr[indexPath.row])")
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    //custom_row_height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    
    //animationToTableView
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    func loadJSON(){
        var json: Any?
        if let path = Bundle.main.path(forResource: "country", ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data)
                
                let fulArray = JSON(json!)
                print(fulArray.count)
                
                for (_, element) in fulArray {
                    dialCodeArr.append(element["dial_code"].stringValue)
                    countryNameArr.append(element["name"].stringValue)
                }
                
                self.filteredCodeData = self.dialCodeArr
                self.filteredCountryData = self.countryNameArr
                
                
            } catch {
                // Handle error here
            }
        }
    }
    
    //LoadSearchBar
    func loadSearchBar(){
        //resultSearchController.isActive = true

        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = true
        resultSearchController.obscuresBackgroundDuringPresentation = false
        resultSearchController.searchBar.placeholder = "Search country name"
        resultSearchController.searchBar.sizeToFit()
        navigationItem.searchController = resultSearchController
       countryTableView.tableHeaderView = resultSearchController.searchBar
        definesPresentationContext = true
    }
   

}//ClassClose
