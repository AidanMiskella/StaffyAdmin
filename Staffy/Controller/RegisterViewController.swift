//
//  RegisterViewController.swift
//  Staffy
//
//  Created by Aidan Miskella on 30/07/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var topImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var firstNameText: UITextField!
    
    @IBOutlet weak var secondNameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        
        //        errorLabel.alpha = 0
        
        Utilities.styleTextField(firstNameText, .textField, .black)
        Utilities.styleTextField(secondNameText, .textField, .black)
        Utilities.styleTextField(emailText, .textField, .black)
        Utilities.styleTextField(passwordText, .textField, .black)
        Utilities.styleFilledButton(submitButton, .largeLoginButton, .white, .lightBlue, 20.0)
        
        topImageHeight.constant = UIScreen.main.bounds.height / 2.25
    }
}
