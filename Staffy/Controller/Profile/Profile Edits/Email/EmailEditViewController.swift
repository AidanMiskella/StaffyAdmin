//
//  EmailEditViewController.swift
//  Staffy
//
//  Created by Aidan Miskella on 26/09/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SCLAlertView

class EmailEditViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        placeholders()
    }
    
    func setupUI() {
        
        topView.layerGradient()
        
        Utilities.styleLabel(label: titleLabel, font: .editProfileTitle, fontColor: .white)
        Utilities.styleTextField(textfield: emailTextField, font: .editProfileText, fontColor: .black, padding: 0.0)
        Utilities.styleFilledButton(button: saveButton, font: .largeLoginButton, fontColor: .white, backgroundColor: .lightBlue, cornerRadius: 10.0)
    }
    
    func placeholders() {
        
        guard let currentUser = UserService.currentUser else { return }
        
        emailTextField.placeholder = currentUser.email
    }
    
    @IBAction func saveButtonDidPress(_ sender: UIButton) {
     
        
    }
}
