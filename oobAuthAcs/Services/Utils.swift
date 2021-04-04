//
//  uiButtonSet.swift
//  oobAuthAcs
//
//  Created by LOB4 on 18/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation
import UIKit


public class myButton {
    class func settings(button:UIButton){
        button.backgroundColor = UIColor.black
        button.tintColor = Common.Global.textColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font =  UIFont(name: "DINAlternate-Bold", size: 20)
    }

}



extension UIViewController {
    func Alert(Title: String, Message: String?) {
        let alertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        DispatchQueue.main.async {
             self.present(alertController, animated: true, completion: nil)
        }
    }
    
 

}


extension String {
    
    //Checks_Whether_String_or_Int
    var isInt: Bool {
        return Int(self) != nil
    }
    //slpitStringsBasedOnlength
    func components(withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}


extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}


extension UIAlertController{
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.tintColor = UIColor.red
    }
}


