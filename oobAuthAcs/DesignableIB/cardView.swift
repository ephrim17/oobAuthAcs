//
//  cardView.swift
//  oobAuthAcs
//
//  Created by LOB4 on 19/11/19.
//  Copyright © 2019 fss. All rights reserved.
//
//
//import Foundation
//import UIKit
//
//@IBDesignable
//class CardView: UIView {
//    
//    @IBInspectable var cornerRadius: CGFloat = 2
//    @IBInspectable var shadowOffsetWidth: Int = 0
//    @IBInspectable var shadowOffsetHeight: Int = 3
//    @IBInspectable var shadowColor: UIColor? = UIColor.blackColor()
//    @IBInspectable var shadowOpacity: Float = 0.5
//    
//    override func layoutSubviews() {
//        layer.cornerRadius = cornerRadius
//        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
//        
//        layer.masksToBounds = false
//        layer.shadowColor = shadowColor?.CGColor
//        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
//        layer.shadowOpacity = shadowOpacity
//        layer.shadowPath = shadowPath.CGPath
//    }
//    
//}
