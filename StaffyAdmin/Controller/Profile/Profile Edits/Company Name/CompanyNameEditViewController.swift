//
//  CompanyNameEditViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 14/10/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class CompanyNameEditViewController: UIViewController {
    
    @IBOutlet weak var companyNameTextField: UITextField!
    
    @IBOutlet weak var companyNameImage: UIImageView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        placeholders()
    }
    
    func setupUI() {
        
        errorLabel.alpha = 0
        
        Utilities.styleTextField(textfield: companyNameTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleLabel(label: errorLabel, font: .loginError, fontColor: .red)
        Utilities.styleImage(imageView: companyNameImage, image: "company", imageColor: .lightGray)
        Utilities.styleFilledButton(button: saveButton, font: .largeLoginButton, fontColor: .white, backgroundColor: .lightBlue, cornerRadius: 10.0)
    }
    
    func placeholders() {
        
        guard let currentCompany = CompanyService.currentCompany else { return }
        
        companyNameTextField.placeholder = currentCompany.companyName
    }
    
    @IBAction func saveButtonDidPress(_ sender: UIButton) {
        
        guard let currentCompany = CompanyService.currentCompany else { return }
        
        if companyNameTextField.text == "" {
            
            errorLabel.alpha = 1
            errorLabel.text = "Please enter a company name."
        } else {
            
            let ref = Firestore.firestore().collection(Constants.FirebaseDB.company_ref)
                .document(Auth.auth().currentUser!.uid)
            
            ref.updateData([
                Constants.FirebaseDB.company_name: companyNameTextField.text!
            ]) { (error) in
                
                if let error = error {
                    
                    print("Error updating information \(error)")
                } else {
                    
                    currentCompany.companyName = self.companyNameTextField.text!
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
