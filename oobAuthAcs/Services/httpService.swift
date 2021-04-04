//
//  httpService.swift
//  oobAuthAcs
//
//  Created by LOB4 on 16/10/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation

//var appUrl = "https://acstest.fssnet.co.in/ACS_OOB/191/"
//var appUrl = "https://acsuat.fssnet.co.in/ACS_OOB/191/"
//var appUrl = "https://acstest.fssnet.co.in/ACS_OOB/190/"
var appUrl = "https://acsuat.fssnet.co.in/ACSOOB/6001/"

//https://acstest.fssnet.co.in/ACS_OOB/123/customerregistration

public class httpService {
    
    func call<GenricClass: Codable>(ClassName: GenricClass,path: String, mycomplete: @escaping (_ result: Data)->()){
        
        print("request Hit=======\(ClassName)")
        
        guard let url = URL(string: appUrl+"\(path)") else { return }
        //guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonBody = try JSONEncoder().encode(ClassName)
            request.httpBody = jsonBody
        }
        catch{
            print("error")
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print(json)
                    mycomplete((data as AnyObject) as! Data)
                    
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    
    func initRequest( mycomplete: @escaping (_ result: Data)->()){
        
        let parameters = ["uniqueId": "123"]
        guard let url = URL(string: "https://acsuat.fssnet.co.in/ACSOOB/6001/getKey") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if response != nil {
                print("Init response received************")
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print(json)
                        mycomplete((data as AnyObject) as! Data)
                        
                    } catch {
                        print(error)
                    }
                }
            }
            else{
                //mycomplete(("Common.Global.errorTitle for the incovenience caused" as AnyObject) as! Data)
                print("Sorry for the incovenience caused")
            }
        }.resume()
    }
    
    func authenticationCall<GenricClass: Codable>(ClassName: GenricClass,givenUrl: String, mycomplete: @escaping (_ result: Data)->()){
        
        print("request Hit=======\(ClassName)")
        print("received URL------\(givenUrl)")
        let sendURL = appUrl + givenUrl
        guard let url = URL(string: sendURL) else {return}
        //guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonBody = try JSONEncoder().encode(ClassName)
            request.httpBody = jsonBody
        }
        catch{
            print("error")
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(json)
                    mycomplete((data as AnyObject) as! Data)
                    
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
