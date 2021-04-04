//
//  Utils.swift
//  oobAuthAcs
//
//  Created by LOB4 on 15/11/19.
//  Copyright © 2019 fss. All rights reserved.
//

import Foundation
import UIKit

public class textFieldSetting{
    
    //addImageToTextField--mail
    public func textFieldImageMail(txtfield: UITextField){
        txtfield.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "mail")
        imageView.image = image
        txtfield.leftView = imageView
    }
    
    //adding_Image_on_textField--key
    public func textFieldImageKey(txtfield: UITextField){
        txtfield.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "key")
        imageView.image = image
        txtfield.leftView = imageView
    }
    
    //adding_Image_on_textField--emailMob
    func textFieldImageMailAndMob(txtfield: UITextField){
        txtfield.rightViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
        let image = UIImage(named: "emailMob")
        imageView.image = image
        txtfield.rightView = imageView
    }
}

//BorderToTextField
extension UITextField {
    func addBottomBorder(){
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
