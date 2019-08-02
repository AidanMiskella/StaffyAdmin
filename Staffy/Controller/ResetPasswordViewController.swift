//
//  ResetPasswordViewController.swift
//  Staffy
//
//  Created by Aidan Miskella on 01/08/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var topImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        
        //        errorLabel.alpha = 0
        
        Utilities.styleTextField(emailText, .textField, .black)
        Utilities.styleFilledButton(submitButton, .largeLoginButton, .white, .lightBlue, 20.0)
        
        topImageHeight.constant = UIScreen.main.bounds.height / 2.25
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
        
    }
}
