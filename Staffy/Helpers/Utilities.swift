//
//  Utilities.swift
//  customauth
//
//  Created by Christopher Ching on 2019-05-09.
//  Copyright © 2019 Christopher Ching. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield: UITextField, _ font: UIFont, _ fontColor: UIColor) {
        
        textfield.font = font
        textfield.textColor = fontColor
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 1, width: textfield.frame.width, height: 1)
        
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: textfield.frame.height))
        textfield.leftView = paddingView
        textfield.leftViewMode = UITextField.ViewMode.always

        
    }
    
    static func styleFilledButton(_ button: UIButton, _ font: UIFont, _ fontColor: UIColor, _ backgroundColor: UIColor, _ cornerRadius: CGFloat) {
        
        button.titleLabel?.font = font
        button.tintColor = fontColor
        
        // Filled rounded corner style
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
    }
    
    static func styleHollowButton(_ button: UIButton, _ font: UIFont, _ fontColor: UIColor, _ borderWidth: CGFloat, _ cornerRadius: CGFloat) {
        
        button.titleLabel?.font = font
        button.tintColor = fontColor
        
        // Hollow rounded corner style
        button.layer.borderWidth = borderWidth
        button.layer.borderColor = fontColor.cgColor
        button.layer.cornerRadius = cornerRadius
    }
    
    static func isPasswordValid(_ password: String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
}

extension UIColor {
    
    static let lightBlue = UIColor(red: 65/255, green: 180/255, blue: 230/255, alpha: 1)
}

extension UIFont {
    
    static let textField = UIFont(name: "Avenir Next", size: 17)!
    static let largeLoginButton = UIFont(name: "AvenirNext-Bold", size: 17)!
}

